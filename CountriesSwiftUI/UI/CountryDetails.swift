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
        Text("Loading...")
    }
    
    private func loadedView(_ countryDetails: Country.Details) -> some View {
        List {
            Section(header: Text("Basic Info")) {
                DetailRow(title: "Code", value: viewModel.country.alpha3Code)
                DetailRow(title: "Population", value: "\(viewModel.country.population)")
                DetailRow(title: "Capital", value: "\(countryDetails.capital)")
            }
            if countryDetails.currencies.count > 0 {
                Section(header: Text("Currencies")) {
                    ForEach(countryDetails.currencies) { currency in
                        DetailRow(title: currency.name, value: currency.code)
                    }
                }
            }
            if countryDetails.neighbors.count > 0 {
                Section(header: Text("Neighboring countries")) {
                    ForEach(countryDetails.neighbors) { country in
                        DetailRow(title: country.name, value: "")
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
}


extension CountryDetails {
    class ViewModel: ContentViewModel<Country.Details> {
        
        let country: Country
        private let container: DIContainer
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
