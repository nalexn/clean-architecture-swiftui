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

// MARK: - ViewModel

extension CountriesList {
    class ViewModel: ObservableObject {
        
        let container: DIContainer
        lazy var countriesSearch = CountriesSearch(searchResultsWillChange: objectWillChange)
        @Published var routingState: Routing
        private var cancelBag = CancelBag()
        
        init(container: DIContainer) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.countriesList)
            $routingState
                .sink { appState[\.routing.countriesList] = $0 }
                .store(in: cancelBag)
            appState.map(\.routing.countriesList)
                .assign(to: \.routingState, on: self)
                .store(in: cancelBag)
            appState.map(\.userData.countries)
                .assign(to: \.countriesSearch.all, on: self)
                .store(in: cancelBag)
            appState.map(\.system.keyboardHeight)
                .assign(to: \.countriesSearch.keyboardHeight, on: self)
                .store(in: cancelBag)
        }
        
        var localeReader: LocaleReader {
            LocaleReader(viewModel: self)
        }
        
        // MARK: - Side effects
        
        func loadCountries() {
            container.services.countriesService
                .loadCountries()
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

// MARK: - Filtering Countries

extension CountriesList.ViewModel {
    struct CountriesSearch {
        
        private(set) var filtered: Loadable<[Country]> = .notRequested {
            willSet { searchResultsWillChange.send() }
        }
        var all: Loadable<[Country]> = .notRequested {
            didSet { filterCountries() }
        }
        var searchText: String = "" {
            didSet { filterCountries() }
        }
        var keyboardHeight: CGFloat = 0
        var locale = Locale.current
        
        private let searchResultsWillChange: ObservableObjectPublisher
        
        init(searchResultsWillChange: ObservableObjectPublisher) {
            self.searchResultsWillChange = searchResultsWillChange
        }
        
        private mutating func filterCountries() {
            if searchText.count == 0 {
                filtered = all
            } else {
                filtered = all.map { countries in
                    countries.filter {
                        $0.name(locale: locale)
                            .range(of: searchText, options: .caseInsensitive,
                                   range: nil, locale: nil) != nil
                    }
                }
            }
        }
    }
}
