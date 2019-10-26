//
//  CountriesList.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 24.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI
import Combine

struct CountriesList: View {
    
    @EnvironmentObject var appState: AppState
    @Environment(\.services) var services: ServicesContainer
    @State private var selectedCounrtyCode: Country.Code? = nil
    
    var body: some View {
        NavigationView {
            content
                .navigationBarTitle("Countries")
        }
    }
    
    // MARK: - Views
    
    private var content: AnyView {
        switch appState.countries {
        case .notRequested: return AnyView(notRequestedView)
        case let .isLoading(last): return AnyView(loadingView(last))
        case let .loaded(countries): return AnyView(loadedView(countries))
        case let .failed(error): return AnyView(failedView(error))
        }
    }
    
    private var notRequestedView: some View {
        Text("").onAppear {
            self.loadCountries()
        }
    }
    
    private func loadingView(_ previouslyLoaded: [Country]?) -> some View {
        VStack {
            ActivityIndicatorView().padding()
            previouslyLoaded.map {
                loadedView($0)
            }
        }
    }
    
    private func loadedView(_ countries: [Country]) -> some View {
        List(countries) { country in
            NavigationLink(
                destination: self.detailsView(country: country),
                tag: country.alpha3Code,
                selection: self.$selectedCounrtyCode) {
                    CountryCell(country: country)
                }
        }
    }
    
    private func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            self.loadCountries()
        })
    }
    
    private func detailsView(country: Country) -> some View {
        CountryDetails(country: country)
    }
    
    private func loadCountries() {
        services.countriesService.loadCountries()
    }
}

#if DEBUG

struct CountriesList_Previews: PreviewProvider {
    static var previews: some View {
        CountriesList()
            .environmentObject(AppState.preview)
    }
}
#endif
