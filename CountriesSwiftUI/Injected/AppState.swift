//
//  AppState.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI
import Combine

struct AppState: Equatable {
    var userData = UserData()
    var routing = ViewRouting()
    var system = System()
}

extension AppState {
    struct UserData: Equatable {
        var countries: Loadable<[Country]> = .notRequested
    }
}

extension AppState {
    struct ViewRouting: Equatable {
        var countriesList = CountriesList.Routing()
        var countryDetails = CountryDetails.Routing()
    }
}

extension AppState {
    struct System: Equatable {
        var isActive: Bool = false
    }
}

func == (lhs: AppState, rhs: AppState) -> Bool {
    return lhs.userData == rhs.userData &&
        lhs.routing == rhs.routing &&
        lhs.system == rhs.system
}

#if DEBUG
extension AppState {
    static var preview: AppState {
        var state = AppState()
        state.userData.countries = .loaded(Country.mockedData)
        state.system.isActive = true
        return state
    }
}
#endif
