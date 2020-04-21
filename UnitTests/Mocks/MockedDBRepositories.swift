//
//  MockedDBRepositories.swift
//  UnitTests
//
//  Created by Alexey Naumov on 18.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import XCTest
import Combine
@testable import CountriesSwiftUI

// MARK: - CountriesWebRepository

final class MockedCountriesDBRepository: Mock, CountriesDBRepository {
    
    enum Action: Equatable {
        case hasLoadedCountries
        case storeCountries([Country])
        case fetchCountries(search: String, locale: Locale)
        case storeCountryDetails(Country.Details.Intermediate)
        case fetchCountryDetails(Country)
    }
    var actions = MockActions<Action>(expected: [])
    
    var hasLoadedCountriesResult: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var storeCountriesResult: Result<Void, Error> = .failure(MockError.valueNotSet)
    var fetchCountriesResult: Result<LazyList<Country>, Error> = .failure(MockError.valueNotSet)
    var storeCountryDetailsResult: Result<Country.Details?, Error> = .failure(MockError.valueNotSet)
    var fetchCountryDetailsResult: Result<Country.Details?, Error> = .failure(MockError.valueNotSet)
    
    // MARK: - API
    
    func hasLoadedCountries() -> AnyPublisher<Bool, Error> {
        register(.hasLoadedCountries)
        return hasLoadedCountriesResult.publish()
    }
    
    func store(countries: [Country]) -> AnyPublisher<Void, Error> {
        register(.storeCountries(countries))
        return storeCountriesResult.publish()
    }
    
    func countries(search: String, locale: Locale) -> AnyPublisher<LazyList<Country>, Error> {
        register(.fetchCountries(search: search, locale: locale))
        return fetchCountriesResult.publish()
    }
    
    func store(countryDetails: Country.Details.Intermediate,
               for country: Country) -> AnyPublisher<Country.Details?, Error> {
        register(.storeCountryDetails(countryDetails))
        return storeCountryDetailsResult.publish()
    }
    
    func countryDetails(country: Country) -> AnyPublisher<Country.Details?, Error> {
        register(.fetchCountryDetails(country))
        return fetchCountryDetailsResult.publish()
    }
}
