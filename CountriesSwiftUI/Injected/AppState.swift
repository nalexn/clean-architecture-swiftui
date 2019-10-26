//
//  AppState.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var countries: Loadable<[Country]> = .notRequested
}

#if DEBUG
extension AppState {
    static var preview: AppState {
        let state = AppState()
        state.countries = .loaded(Country.sampleData)
        return state
    }
}
#endif
