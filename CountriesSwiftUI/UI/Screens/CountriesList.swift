//
//  CountriesList.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 24.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - Routing

extension CountriesList {
    struct Routing: Equatable {
        var countryDetails: Country.Code? = nil
    }
}

// MARK: - CountriesList

struct CountriesList: View {
    
    @EnvironmentObject var appState: AppState
    @Environment(\.interactors) var interactors: InteractorsContainer
    
    var body: some View {
        NavigationView {
            content
                .navigationBarTitle("Countries")
        }
    }
    
    private var content: AnyView {
        switch appState.userData.countries {
        case .notRequested: return AnyView(notRequestedView)
        case let .isLoading(last): return AnyView(loadingView(last))
        case let .loaded(countries): return AnyView(loadedView(countries))
        case let .failed(error): return AnyView(failedView(error))
        }
    }
}

// MARK: - Side Effects

private extension CountriesList {
    func loadCountries() {
        interactors.countriesInteractor.loadCountries()
    }
}

// MARK: - Loading Content

private extension CountriesList {
    var notRequestedView: some View {
        Text("").onAppear {
            self.loadCountries()
        }
    }
    
    func loadingView(_ previouslyLoaded: [Country]?) -> some View {
        VStack {
            ActivityIndicatorView().padding()
            previouslyLoaded.map {
                loadedView($0)
            }
        }
    }
    
    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            self.loadCountries()
        })
    }
}

// MARK: - Displaying Content

private extension CountriesList {
    func loadedView(_ countries: [Country]) -> some View {
        return List(countries) { country in
            NavigationLink(
                destination: self.detailsView(country: country),
                tag: country.alpha3Code,
                selection: self.$appState.routing.countriesList.countryDetails) {
                    CountryCell(country: country)
                }
        }
    }
    
    func detailsView(country: Country) -> some View {
        CountryDetails(country: country)
    }
}

#if DEBUG
struct CountriesList_Previews: PreviewProvider {
    static var appState = AppState.preview
    static var previews: some View {
        CountriesList()
            .environmentObject(appState)
    }
}
#endif
