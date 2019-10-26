//
//  CountryDetails.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 25.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI
import Combine

struct CountryDetails: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        content
            .navigationBarTitle(viewModel.country.name)
    }
    
    private var content: AnyView {
        switch viewModel.content {
        case .notRequested: return AnyView(notRequestedView)
        case .isLoading: return AnyView(loadingView)
        case let .loaded(countryDetails): return AnyView(loadedView(countryDetails))
        case let .failed(error): return AnyView(failedView(error))
        }
    }
    
    private var notRequestedView: some View {
        Text("").onAppear {
            self.viewModel.loadCountryDetails()
        }
    }
    
    private var loadingView: some View {
        ActivityIndicatorView()
    }
    
    private func loadedView(_ countryDetails: Country.Details) -> some View {
        List {
            viewModel.country.flag.map { url in
                HStack {
                    Spacer()
                    SVGImageView(imageURL: url)
                        .frame(width: 120, height: 80)
                    Spacer()
                }
            }
            Section(header: Text("Basic Info")) {
                DetailRow(leftLabel: viewModel.country.alpha3Code, rightLabel: "Code")
                DetailRow(leftLabel: "\(viewModel.country.population)", rightLabel: "Population")
                DetailRow(leftLabel: "\(countryDetails.capital)", rightLabel: "Capital")
            }
            if countryDetails.currencies.count > 0 {
                Section(header: Text("Currencies")) {
                    ForEach(countryDetails.currencies) { currency in
                        DetailRow(leftLabel: currency.title, rightLabel: currency.code)
                    }
                }
            }
            if countryDetails.neighbors.count > 0 {
                Section(header: Text("Neighboring countries")) {
                    ForEach(countryDetails.neighbors) { country in
                        NavigationLink(destination: self.detailsView(country: country)) {
                            DetailRow(leftLabel: country.name, rightLabel: "")
                        }
                    }
                }
            }
        }.listStyle(GroupedListStyle())
    }
    
    private func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            self.viewModel.loadCountryDetails()
        })
    }
    
    private func detailsView(country: Country) -> some View {
        CountryDetails(viewModel: CountryDetails.ViewModel(
            container: viewModel.container, country: country))
    }
}

private extension Country.Currency {
    var title: String {
        if let symbol = symbol {
            return name + " \(symbol)"
        } else { return name }
    }
}

extension CountryDetails {
    class ViewModel: ContentViewModel<Country.Details> {
        
        let country: Country
        let container: DIContainer
        private let details = CurrentValueSubject<Loadable<Country.Details>, Never>(.notRequested)
        private var requestToken: Cancellable?
        
        init(container: DIContainer, country: Country) {
            self.container = container
            self.country = country
            super.init(publisher: details.eraseToAnyPublisher(),
                       hasDataToDisplay: { $0.value != nil })
        }
        
        func loadCountryDetails() {
            requestToken?.cancel()
            requestToken = container.countriesService
                .load(countryDetails: details, country: country)
        }
    }
}

#if DEBUG

extension CountryDetails.ViewModel {
    static var preview: CountryDetails.ViewModel {
        let viewModel = CountryDetails.ViewModel(container:
            DIContainer(presetCountries: .loaded(Country.sampleData)),
                                 country: Country.sampleData[0])
        viewModel.details.send(.loaded(Country.Details.sampleData[0]))
        return viewModel
    }
}

struct CountryDetails_Previews: PreviewProvider {
    static var previews: some View {
        CountryDetails(viewModel: CountryDetails.ViewModel.preview)
    }
}
#endif
