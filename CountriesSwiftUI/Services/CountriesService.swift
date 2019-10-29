//
//  CountriesService.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

protocol CountriesService {
    func loadCountries()
    func load(countryDetails: Binding<Loadable<Country.Details>>, country: Country)
}

struct RealCountriesService: CountriesService {
    
    let webRepository: CountriesWebRepository
    let appState: AppState
    
    init(webRepository: CountriesWebRepository, appState: AppState) {
        self.webRepository = webRepository
        self.appState = appState
    }

    func loadCountries() {
        appState.userData.countries = .isLoading(last: appState.userData.countries.value)
        weak var weakAppState = appState
        _ = webRepository.loadCountries()
            .map { Loadable<[Country]>.loaded($0) }
            .catch { Just<Loadable<[Country]>>(.failed($0)) }
            .sink { weakAppState?.userData.countries = $0 }
    }

    func load(countryDetails: Binding<Loadable<Country.Details>>, country: Country) {
        countryDetails.wrappedValue = .isLoading(last: countryDetails.wrappedValue.value)
        _ = webRepository.loadCountryDetails(country: country)
            .map { Loadable<Country.Details>.loaded($0) }
            .catch { Just<Loadable<Country.Details>>(.failed($0)) }
            .sink { countryDetails.wrappedValue = $0 }
    }
}

struct FakeCountriesService: CountriesService {
    
    func loadCountries() {
    }
    
    func load(countryDetails: Binding<Loadable<Country.Details>>, country: Country) {
    }
}
