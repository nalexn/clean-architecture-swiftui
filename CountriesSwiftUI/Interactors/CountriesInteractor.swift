//
//  CountriesInteractor.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

protocol CountriesInteractor {
    func loadCountries() -> AnyCancellable
    func load(countryDetails: Binding<Loadable<Country.Details>>, country: Country) -> AnyCancellable
}

struct RealCountriesInteractor: CountriesInteractor {
    
    let webRepository: CountriesWebRepository
    let appState: AppState
    
    init(webRepository: CountriesWebRepository, appState: AppState) {
        self.webRepository = webRepository
        self.appState = appState
    }

    func loadCountries() -> AnyCancellable {
        appState.userData.countries = .isLoading(last: appState.userData.countries.value)
        weak var weakAppState = appState
        return webRepository.loadCountries()
            .sinkToLoadable { weakAppState?.userData.countries = $0 }
    }

    func load(countryDetails: Binding<Loadable<Country.Details>>, country: Country) -> AnyCancellable {
        countryDetails.wrappedValue = .isLoading(last: countryDetails.wrappedValue.value)
        let countriesArray = appState.$userData
            .tryMap { userData -> [Country] in
                if let error = userData.countries.error {
                    throw error
                }
                return userData.countries.value ?? []
            }
        return webRepository.loadCountryDetails(country: country)
            .combineLatest(countriesArray)
            .receive(on: webRepository.bgQueue)
            .map { (intermediate, countries) -> Country.Details in
                intermediate.substituteNeighbors(countries: countries)
            }
            .receive(on: DispatchQueue.main)
            .sinkToLoadable { countryDetails.wrappedValue = $0 }
    }
}

struct StubCountriesInteractor: CountriesInteractor {
    
    func loadCountries() -> AnyCancellable {
        return .cancelled
    }
    
    func load(countryDetails: Binding<Loadable<Country.Details>>, country: Country) -> AnyCancellable {
        return .cancelled
    }
}
