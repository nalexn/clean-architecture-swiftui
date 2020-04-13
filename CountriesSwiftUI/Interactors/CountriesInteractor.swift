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
    func load(countries: LoadableSubject<[Country]>, search: String, locale: Locale)
    func load(countryDetails: LoadableSubject<Country.Details>, country: Country)
}

struct RealCountriesInteractor: CountriesInteractor {
    
    let webRepository: CountriesWebRepository
    let dbRepository: CountriesDBRepository
    let appState: Store<AppState>
    
    init(webRepository: CountriesWebRepository, dbRepository: CountriesDBRepository, appState: Store<AppState>) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.appState = appState
    }

    func load(countries: LoadableSubject<[Country]>, search: String, locale: Locale) {
        
        let cancelBag = CancelBag()
        countries.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        let shouldLoadFromWeb = !dbRepository.hasLoadedCountries()
        
        Just<Void>
            .withErrorType()
            .flatMap { _ -> AnyPublisher<Void, Error> in
                return shouldLoadFromWeb ? self.loadAndStoreCountriesFromWeb() : Just<Void>.withErrorType()
            }
            .flatMap { [dbRepository] in
                dbRepository.countries(search: search, locale: locale)
            }
            .sinkToLoadable { countries.wrappedValue = $0 }
            .store(in: cancelBag)
    }
    
    private func loadAndStoreCountriesFromWeb() -> AnyPublisher<Void, Error> {
        webRepository
            .loadCountries()
            .flatMap { [dbRepository] in
                dbRepository.store(countries: $0)
            }
            .eraseToAnyPublisher()
    }

    func load(countryDetails: LoadableSubject<Country.Details>, country: Country) {
        
        let cancelBag = CancelBag()
        countryDetails.wrappedValue.setIsLoading(cancelBag: cancelBag)

        dbRepository
            .countryDetails(country: country)
            .flatMap { details -> AnyPublisher<Country.Details?, Error> in
                if details != nil {
                    return Just<Country.Details?>.withErrorType(details)
                } else {
                    return self.loadAndStoreCountryDetailsFromWeb(country: country)
                }
            }
            .sinkToLoadable { countryDetails.wrappedValue = $0.unwrap() }
            .store(in: cancelBag)
    }
    
    private func loadAndStoreCountryDetailsFromWeb(country: Country) -> AnyPublisher<Country.Details?, Error> {
        return webRepository
            .loadCountryDetails(country: country)
            .flatMap { [dbRepository] in
                dbRepository.store(countryDetails: $0)
            }
            .eraseToAnyPublisher()
    }
}

struct StubCountriesInteractor: CountriesInteractor {
    
    func load(countries: LoadableSubject<[Country]>, search: String, locale: Locale) {
    }
    
    func load(countryDetails: LoadableSubject<Country.Details>, country: Country) {
    }
}
