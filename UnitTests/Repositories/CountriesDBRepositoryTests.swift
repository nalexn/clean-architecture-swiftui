//
//  CountriesDBRepositoryTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 19.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import XCTest
import Combine
@testable import CountriesSwiftUI

class CountriesDBRepositoryTests: XCTestCase {
    
    var mockedStore: MockedPersistentStore!
    var sut: RealCountriesDBRepository!
    var cancelBag = CancelBag()
    
    override func setUp() {
        mockedStore = MockedPersistentStore()
        sut = RealCountriesDBRepository(persistentStore: mockedStore)
        mockedStore.verify()
    }
    
    override func tearDown() {
        cancelBag = CancelBag()
        sut = nil
        mockedStore = nil
    }
}

// MARK: - Countries list
    
final class CountriesListDBRepoTests: CountriesDBRepositoryTests {

    func test_hasLoadedCountries() {
        mockedStore.actions = .init(expected: [
            .count,
            .count
        ])
        let exp = XCTestExpectation(description: #function)
        mockedStore.countResult = 0
        sut.hasLoadedCountries()
            .flatMap { value -> AnyPublisher<Bool, Error> in
                XCTAssertFalse(value)
                self.mockedStore.countResult = 10
                return self.sut.hasLoadedCountries()
            }
            .sinkToResult { result in
                result.assertSuccess(value: true)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_storeCountries() {
        let countries = Country.mockedData
        mockedStore.actions = .init(expected: [
            .update(.init(inserted: countries.count, updated: 0, deleted: 0))
        ])
        let exp = XCTestExpectation(description: #function)
        sut.store(countries: countries)
            .sinkToResult { result in
                result.assertSuccess()
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_fetchAllCountries() throws {
        let countries = Country.mockedData
        let sortedCountries = countries.sorted(by: { $0.name < $1.name })
        mockedStore.actions = .init(expected: [
            .fetchCountries(.init(inserted: 0, updated: 0, deleted: 0))
        ])
        try mockedStore.preloadData { context in
            countries.forEach { $0.store(in: context) }
        }
        let exp = XCTestExpectation(description: #function)
        sut
            .countries(search: "", locale: .backendDefault)
            .sinkToResult { result in
                result.assertSuccess(value: sortedCountries.lazyList)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_fetchInNames() throws {
        let countries = Country.testLocalized
        mockedStore.actions = .init(expected: [
            .fetchCountries(.init(inserted: 0, updated: 0, deleted: 0))
        ])
        try mockedStore.preloadData { context in
            countries.forEach { $0.store(in: context) }
        }
        let exp = XCTestExpectation(description: #function)
        sut
            .countries(search: "nited stat", locale: Locale(identifier: "fr"))
            .sinkToResult { result in
                let expected = [countries[0]]
                result.assertSuccess(value: expected.lazyList)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_fetchInTranspaltions() throws {
        let countries = Country.testLocalized
        mockedStore.actions = .init(expected: [
            .fetchCountries(.init(inserted: 0, updated: 0, deleted: 0))
        ])
        try mockedStore.preloadData { context in
            countries.forEach { $0.store(in: context) }
        }
        let exp = XCTestExpectation(description: #function)
        sut
            .countries(search: "in frénch", locale: Locale(identifier: "fr"))
            .sinkToResult { result in
                let expected = [countries[2], countries[0]]
                result.assertSuccess(value: expected.lazyList)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
}

private extension Country {
    static var testLocalized: [Country] {
        [
        Country(name: "United States",
                translations: ["fr": "United States in Frénch",
                               "ja": "Unitd States in Japaneese"],
                population: 125000000,
                flag: URL(string: "https://flagcdn.com/us.svg"),
                alpha3Code: "USA"),
        Country(name: "Canada",
                translations: ["ja": "Canada not in French"],
                population: 57600000,
                flag: nil,
                alpha3Code: "CAN"),
        Country(name: "Georgia",
            translations: ["fr": "Georgia in French",
                           "ja": "United States not in Japaneese"],
            population: 2340000,
            flag: nil,
            alpha3Code: "GEO")
        ]
    }
}

private extension Country.Details {
    static var test: Country.Details {
        return Country.Details(
            capital: "Sin City",
            currencies: [Country.Currency(code: "code", symbol: "$", name: "USD")],
            neighbors: Array(Country.testLocalized[0..<2])
                .sorted(by: { $0.name < $1.name }))
    }
}

// MARK: - Countries list
    
final class CountryDetailsDBRepoTests: CountriesDBRepositoryTests {
    
    func test_storeCountryDetails() throws {
        let details = Country.Details.test
        let intermediate = Country.Details.Intermediate(
            capital: details.capital, currencies: details.currencies,
            borders: details.neighbors.map { $0.alpha3Code })
        let parentCountry = Country.testLocalized[2]
        mockedStore.actions = .init(expected: [
            .update(.init(inserted: 1 + details.currencies.count, // self + currencies
                          updated: details.neighbors.count + 1, // neighbors + parent
                          deleted: 0))
        ])
        try mockedStore.preloadData { context in
            parentCountry.store(in: context)
            details.neighbors.forEach { $0.store(in: context) }
        }
        let exp = XCTestExpectation(description: #function)
        sut.store(countryDetails: intermediate, for: parentCountry)
            .sinkToResult { result in
                result.assertSuccess(value: details)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_fetchCountryDetails() throws {
        let details = Country.Details.test
        let intermediate = Country.Details.Intermediate(
            capital: details.capital, currencies: details.currencies,
            borders: details.neighbors.map { $0.alpha3Code })
        let parentCountry = Country.testLocalized[2]
        mockedStore.actions = .init(expected: [
            .fetchCountryDetails(.init(inserted: 0, updated: 0, deleted: 0))
        ])
        try mockedStore.preloadData { context in
            let parent = parentCountry.store(in: context)
            let neighbors = details.neighbors.compactMap { $0.store(in: context) }
            _ = parent.flatMap {
                intermediate.store(in: context, country: $0, borders: neighbors)
            }
        }
        let exp = XCTestExpectation(description: #function)
        sut.countryDetails(country: parentCountry)
            .sinkToResult { result in
                result.assertSuccess(value: details)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
}
