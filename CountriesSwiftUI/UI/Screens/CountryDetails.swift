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
    @EnvironmentObject var appState: AppState
    @Environment(\.services) var services: ServicesContainer
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
    
    private var notRequestedView: some View {
        Text("").onAppear {
            self.loadCountryDetails()
        }
    }
    
    private var loadingView: some View {
        ActivityIndicatorView()
    }
    
    private func loadedView(_ countryDetails: Country.Details) -> some View {
        List {
            country.flag.map { url in
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
            Section(header: Text("Basic Info")) {
                DetailRow(leftLabel: country.alpha3Code, rightLabel: "Code")
                DetailRow(leftLabel: "\(country.population)", rightLabel: "Population")
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
        }
        .listStyle(GroupedListStyle())
        .sheet(isPresented: self.$appState.routing.countryDetails.detailsSheet, content: {
            ModalDetailsView(country: self.country, isDisplayed: self.$appState.routing.countryDetails.detailsSheet)
        })
    }
    
    private func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            self.loadCountryDetails()
        })
    }
    
    private func detailsView(country: Country) -> some View {
        CountryDetails(country: country)
    }
    
    private func loadCountryDetails() {
        services.countriesService.load(countryDetails: $details, country: country)
    }
}

extension CountryDetails {
    struct Routing {
        var detailsSheet: Bool = false
    }
}

private extension Country.Currency {
    var title: String {
        if let symbol = symbol {
            return name + " \(symbol)"
        } else { return name }
    }
}

#if DEBUG

struct CountryDetails_Previews: PreviewProvider {
    static var previews: some View {
        CountryDetails(country: Country.sampleData[0])
            .environmentObject(AppState.preview)
    }
}
#endif
