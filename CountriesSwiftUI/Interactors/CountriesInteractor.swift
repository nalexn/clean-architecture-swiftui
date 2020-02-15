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
    func loadCountries()
    func load(countryDetails: Binding<Loadable<Country.Details>>, country: Country)
}

struct RealCountriesInteractor: CountriesInteractor {
    
    let webRepository: CountriesWebRepository
    let appState: Store<AppState>
    
    init(webRepository: CountriesWebRepository, appState: Store<AppState>) {
        self.webRepository = webRepository
        self.appState = appState
    }

    func loadCountries() {
        let countries = appState.value.userData.countries.value
        let cancelBag = CancelBag()
        appState[\.userData.countries] = .isLoading(last: countries, cancelBag: cancelBag)
        weak var weakAppState = appState
        webRepository.loadCountries()
            .sinkToLoadable { weakAppState?[\.userData.countries] = $0 }
            .store(in: cancelBag)
    }

    func load(countryDetails: Binding<Loadable<Country.Details>>, country: Country) {
        let cancelBag = CancelBag()
        countryDetails.wrappedValue = .isLoading(last: countryDetails.wrappedValue.value,
                                                 cancelBag: cancelBag)
        let countriesArray = appState
            .map { $0.userData.countries }
            .tryMap { countries -> [Country] in
                if let error = countries.error {
                    throw error
                }
                return countries.value ?? []
            }
        webRepository.loadCountryDetails(country: country)
            .combineLatest(countriesArray)
            .receive(on: webRepository.bgQueue)
            .map { (intermediate, countries) -> Country.Details in
                intermediate.substituteNeighbors(countries: countries)
            }
            .receive(on: DispatchQueue.main)
            .sinkToLoadable { countryDetails.wrappedValue = $0 }
            .store(in: cancelBag)
    }
}

struct StubCountriesInteractor: CountriesInteractor {
    
    func loadCountries() {
    }
    
    func load(countryDetails: Binding<Loadable<Country.Details>>, country: Country) {
    }
}
