//
//  CountryDetailsViewModel.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 04.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - Routing

extension CountryDetails {
    struct Routing: Equatable {
        var detailsSheet: Bool = false
    }
}

// MARK: - ViewModel

extension CountryDetails {
    class ViewModel: ObservableObject {
        
        // State
        let country: Country
        @Published var routingState: Routing
        @Published var details: Loadable<Country.Details>
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(container: DIContainer, country: Country,
             details: Loadable<Country.Details> = .notRequested) {
            self.container = container
            self.country = country
            let appState = container.appState
            _details = .init(initialValue: details)
            _routingState = .init(initialValue: appState.value.routing.countryDetails)
            cancelBag.collect {
                $routingState
                    .sink { appState[\.routing.countryDetails] = $0 }
                appState.map(\.routing.countryDetails)
                    .removeDuplicates()
                    .weakAssign(to: \.routingState, on: self)
            }
        }
        
        // MARK: - Side Effects
        
        func loadCountryDetails() {
            container.services.countriesService
                .load(countryDetails: loadableSubject(\.details), country: country)
        }
        
        func showCountryDetailsSheet() {
            routingState.detailsSheet = true
        }
    }
}
