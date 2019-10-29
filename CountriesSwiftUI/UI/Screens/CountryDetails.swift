//
//  CountryDetails.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 25.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - Routing

extension CountryDetails {
    struct Routing {
        var detailsSheet: Bool = false
    }
}

// MARK: - CountryDetails

struct CountryDetails: View {
    
    let country: Country
    @EnvironmentObject var appState: AppState
    @Environment(\.interactors) var interactors: InteractorsContainer
    @State private var details: Loadable<Country.Details> = .notRequested
    
    var body: some View {
        content
            .navigationBarTitle(country.name)
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
        interactors.countriesInteractor.load(countryDetails: $details, country: country)
    }
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
        .sheet(isPresented: self.$appState.routing.countryDetails.detailsSheet,
               content: { self.modalDetailsView() })
    }
    
    func flagView(url: URL) -> some View {
        HStack {
            Spacer()
            SVGImageView(imageURL: url)
                .frame(width: 120, height: 80)
                .onTapGesture {
                    self.appState.routing.countryDetails.detailsSheet = true
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
                         isDisplayed: $appState.routing.countryDetails.detailsSheet)
            .modifier(RootViewModifier(appState: appState,
                                       interactors: interactors))
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

// MARK: - Preview

#if DEBUG
struct CountryDetails_Previews: PreviewProvider {
    static var previews: some View {
        CountryDetails(country: Country.mockedData[0])
            .environmentObject(AppState.preview)
    }
}
#endif
