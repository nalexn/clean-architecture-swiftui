//
//  CountriesListViewModel.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 04.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - Routing

extension CountriesList {
    struct Routing: Equatable {
        var countryDetails: Country.Code?
    }
}

// MARK: - Search State

extension CountriesList {
    struct CountriesSearch {
        var searchText: String = ""
        var keyboardHeight: CGFloat = 0
        var locale: Locale = .backendDefault
    }
}

// MARK: - ViewModel

extension CountriesList {
    class ViewModel: ObservableObject {
        
        // State
        @Published var routingState: Routing
        @Published var countriesSearch = CountriesSearch()
        @Published var countries: Loadable<LazyList<Country>>
        @Published var canRequestPushPermission: Bool = false
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(container: DIContainer, countries: Loadable<LazyList<Country>> = .notRequested) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.countriesList)
            _countries = .init(initialValue: countries)
            cancelBag.collect {
                $routingState
                    .sink { appState[\.routing.countriesList] = $0 }
                appState.map(\.routing.countriesList)
                    .removeDuplicates()
                    .weakAssign(to: \.routingState, on: self)
                appState.updates(for: AppState.permissionKeyPath(for: .pushNotifications))
                    .map { $0 == .notRequested || $0 == .denied }
                    .weakAssign(to: \.canRequestPushPermission, on: self)
            }
        }
        
        var localeReader: LocaleReader {
            LocaleReader(viewModel: self)
        }
        
        // MARK: - Side Effects
        
        func reloadCountries() {
            container.services.countriesService
                .load(countries: loadableSubject(\.countries),
                      search: countriesSearch.searchText,
                      locale: countriesSearch.locale)
        }
        
        func requestPushPermission() {
            container.services.userPermissionsService
                .request(permission: .pushNotifications)
        }
    }
}

// MARK: - Locale Reader

extension CountriesList {
    struct LocaleReader: EnvironmentalModifier {
        
        let viewModel: ViewModel
        
        func resolve(in environment: EnvironmentValues) -> some ViewModifier {
            viewModel.countriesSearch.locale = environment.locale
            return DummyViewModifier()
        }
        
        private struct DummyViewModifier: ViewModifier {
            func body(content: Content) -> some View {
                // Cannot return just `content` because SwiftUI
                // flattens modifiers that do nothing to the `content`
                content.onAppear()
            }
        }
    }
}
