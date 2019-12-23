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
    
    let country: Country
    private let cancelBag = CancelBag()
    
    @Environment(\.injected) private var injected: DIContainer
    @State private var details: Loadable<Country.Details>
    @State private var routingState: Routing = .init()
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.countryDetails)
    }
    
    init(country: Country, details: Loadable<Country.Details> = .notRequested) {
        self.country = country
        self._details = .init(initialValue: details)
    }
    
    var body: some View {
        #if targetEnvironment(simulator)
        let isiPhoneSimulator = UIDevice.current.userInterfaceIdiom == .phone
        return content
            .navigationBarTitle(country.name)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                self.goBack()
            }, label: { Text(isiPhoneSimulator ? "Back" : "") }))
            .onReceive(routingUpdate) { self.routingState = $0 }
        #else
        return content
            .navigationBarTitle(country.name)
            .onReceive(routingUpdate) { self.routingState = $0 }
        #endif
    }
    
    private var content: AnyView {
        switch details {
        case .notRequested: return AnyView(notRequestedView)
        case .isLoading: return AnyView(loadingView)
        case let .loaded(countryDetails): return AnyView(loadedView(countryDetails))
        case let .failed(error): return AnyView(failedView(error))
        }
    }
}

// MARK: - Side Effects

private extension CountryDetails {
    func loadCountryDetails() {
        injected.interactors.countriesInteractor
            .load(countryDetails: $details, country: country)
            .store(in: cancelBag)
    }
    
    func showCountryDetailsSheet() {
        injected.appState[\.routing.countryDetails.detailsSheet] = true
    }
    
    #if targetEnvironment(simulator)
    func goBack() {
        injected.appState[\.routing.countriesList.countryDetails] = nil
    }
    #endif
}

// MARK: - Loading Content

private extension CountryDetails {
    var notRequestedView: some View {
        Text("").onAppear {
            self.loadCountryDetails()
        }
    }
    
    var loadingView: some View {
        ActivityIndicatorView()
    }
    
    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            self.loadCountryDetails()
        })
    }
}

// MARK: - Displaying Content

private extension CountryDetails {
    func loadedView(_ countryDetails: Country.Details) -> some View {
        List {
            country.flag.map { url in
                flagView(url: url)
            }
            basicInfoSectionView(countryDetails: countryDetails)
            if countryDetails.currencies.count > 0 {
                currenciesSectionView(currencies: countryDetails.currencies)
            }
            if countryDetails.neighbors.count > 0 {
                neighborsSectionView(neighbors: countryDetails.neighbors)
            }
        }
        .listStyle(GroupedListStyle())
        .sheet(isPresented: routingBinding.detailsSheet,
               content: { self.modalDetailsView() })
    }
    
    func flagView(url: URL) -> some View {
        HStack {
            Spacer()
            SVGImageView(imageURL: url)
                .frame(width: 120, height: 80)
                .onTapGesture {
                    self.showCountryDetailsSheet()
                }
            Spacer()
        }
    }
    
    func basicInfoSectionView(countryDetails: Country.Details) -> some View {
        Section(header: Text("Basic Info")) {
            DetailRow(leftLabel: country.alpha3Code, rightLabel: "Code")
            DetailRow(leftLabel: "\(country.population)", rightLabel: "Population")
            DetailRow(leftLabel: "\(countryDetails.capital)", rightLabel: "Capital")
        }
    }
    
    func currenciesSectionView(currencies: [Country.Currency]) -> some View {
        Section(header: Text("Currencies")) {
            ForEach(currencies) { currency in
                DetailRow(leftLabel: currency.title, rightLabel: currency.code)
            }
        }
    }
    
    func neighborsSectionView(neighbors: [Country]) -> some View {
        Section(header: Text("Neighboring countries")) {
            ForEach(neighbors) { country in
                NavigationLink(destination: self.neighbourDetailsView(country: country)) {
                    DetailRow(leftLabel: country.name, rightLabel: "")
                }
            }
        }
    }
    
    func neighbourDetailsView(country: Country) -> some View {
        CountryDetails(country: country)
    }
    
    func modalDetailsView() -> some View {
        ModalDetailsView(country: country,
                         isDisplayed: routingBinding.detailsSheet)
            .modifier(RootViewAppearance())
            .modifier(DIContainer.Injector(container: injected))
            
    }
}

// MARK: - Helpers

private extension Country.Currency {
    var title: String {
        if let symbol = symbol {
            return name + " \(symbol)"
        } else { return name }
    }
}

// MARK: - Routing

extension CountryDetails {
    struct Routing: Equatable {
        var detailsSheet: Bool = false
    }
}

// MARK: - State Updates

private extension CountryDetails {
    
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.countryDetails)
    }
}

// MARK: - Preview

#if DEBUG
struct CountryDetails_Previews: PreviewProvider {
    static var previews: some View {
        CountryDetails(country: Country.mockedData[0])
            .modifier(DIContainer.Injector.preview)
    }
}
#endif
