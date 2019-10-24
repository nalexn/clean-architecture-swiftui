//
//  DIContainer.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 24.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Foundation

struct DIContainer {
    let appState: AppState
    let countriesService: CountriesServiceProtocol
}

#if DEBUG
extension DIContainer {
    init(presetCountries: Loadable<[Country]>) {
        self.appState = AppState()
        self.countriesService = MockedCountriesService(countries: presetCountries)
    }
}
#endif

