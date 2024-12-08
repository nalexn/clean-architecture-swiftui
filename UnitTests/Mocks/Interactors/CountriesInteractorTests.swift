//
//  CountriesInteractorTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 31.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Testing
import SwiftUI
@testable import CountriesSwiftUI

@MainActor
@Suite class CountriesInteractorTests {

    let mockedWebRepo: MockedCountriesWebRepository
    let mockedDBRepo: MockedCountriesDBRepository
    let sut: RealCountriesInteractor

    init() {
        mockedWebRepo = MockedCountriesWebRepository()
        mockedDBRepo = MockedCountriesDBRepository()
        sut = RealCountriesInteractor(webRepository: mockedWebRepo,
                                      dbRepository: mockedDBRepo)
    }
}

// MARK: - refreshCountriesList()

final class RefreshCountriesListTests: CountriesInteractorTests {

    @Test func happyPath() async throws {
        let countries = ApiModel.Country.mockedData
        mockedWebRepo.actions = .init(expected: [
            .countries
        ])
        mockedWebRepo.countriesResponses = [.success(countries)]
        mockedDBRepo.actions = .init(expected: [
            .storeCountries(countries)
        ])
        mockedDBRepo.storeCountriesResults = [.success(())]
        try await sut.refreshCountriesList()
        mockedWebRepo.verify()
        mockedDBRepo.verify()
    }

    @Test func dbFailure() async throws {
        let countries = ApiModel.Country.mockedData
        mockedWebRepo.actions = .init(expected: [
            .countries
        ])
        mockedWebRepo.countriesResponses = [.success(countries)]
        mockedDBRepo.actions = .init(expected: [
            .storeCountries(countries)
        ])
        let error = NSError.test
        mockedDBRepo.storeCountriesResults = [.failure(error)]
        await #expect(throws: error) {
            try await sut.refreshCountriesList()
        }
        mockedWebRepo.verify()
        mockedDBRepo.verify()
    }

    @Test func webFailure() async throws {
        mockedWebRepo.actions = .init(expected: [
            .countries
        ])
        let error = NSError.test
        mockedWebRepo.countriesResponses = [.failure(error)]
        mockedDBRepo.actions = .init(expected: [])
        await #expect(throws: error) {
            try await sut.refreshCountriesList()
        }
        mockedWebRepo.verify()
        mockedDBRepo.verify()
    }
}

// MARK: - loadCountryDetails(country: DBModel.Country, forceReload: Bool)

final class LoadCountryDetailsTests: CountriesInteractorTests {

    @Test func happyPathCachedData() async throws {
        let country = ApiModel.Country.mockedData[0].dbModel()
        let details = ApiModel.CountryDetails.mockedData[0]
        mockedWebRepo.actions = .init(expected: [])
        mockedDBRepo.actions = .init(expected: [
            .fetchCountryDetails(country),
        ])
        let dbDetails = DBModel.CountryDetails(
            alpha3Code: country.alpha3Code,
            capital: details.capital,
            currencies: details.currencies.map({ $0.dbModel() }),
            neighbors: [])
        mockedDBRepo.countryDetailsResults = [
            .success(dbDetails)
        ]
        let result = try await sut.loadCountryDetails(country: country, forceReload: false)
        #expect(result == dbDetails)
        mockedWebRepo.verify()
        mockedDBRepo.verify()
    }

    @Test func happyPathCachedDataForceReload() async throws {
        let country = ApiModel.Country.mockedData[0].dbModel()
        let details = ApiModel.CountryDetails.mockedData[0]
        mockedWebRepo.actions = .init(expected: [
            .details(country: country),
        ])
        mockedWebRepo.detailsResponses = [.success(details)]
        mockedDBRepo.actions = .init(expected: [
            .storeDetails(details, country: country),
            .fetchCountryDetails(country),
        ])
        let dbDetails = DBModel.CountryDetails(
            alpha3Code: country.alpha3Code,
            capital: details.capital,
            currencies: details.currencies.map({ $0.dbModel() }),
            neighbors: [])
        mockedDBRepo.countryDetailsResults = [
            .success(dbDetails)
        ]
        mockedDBRepo.storeCountryDetailsResults = [.success(())]
        let result = try await sut.loadCountryDetails(country: country, forceReload: true)
        #expect(result == dbDetails)
        mockedWebRepo.verify()
        mockedDBRepo.verify()
    }

    @Test func happyPathNoCache() async throws {
        let country = ApiModel.Country.mockedData[0].dbModel()
        let details = ApiModel.CountryDetails.mockedData[0]
        mockedWebRepo.actions = .init(expected: [
            .details(country: country),
        ])
        mockedWebRepo.detailsResponses = [.success(details)]
        mockedDBRepo.actions = .init(expected: [
            .fetchCountryDetails(country),
            .storeDetails(details, country: country),
            .fetchCountryDetails(country),
        ])
        let dbDetails = DBModel.CountryDetails(
            alpha3Code: country.alpha3Code,
            capital: details.capital,
            currencies: details.currencies.map({ $0.dbModel() }),
            neighbors: [])
        mockedDBRepo.countryDetailsResults = [
            .success(nil),
            .success(dbDetails)
        ]
        mockedDBRepo.storeCountryDetailsResults = [.success(())]
        let result = try await sut.loadCountryDetails(country: country, forceReload: false)
        #expect(result == dbDetails)
        mockedWebRepo.verify()
        mockedDBRepo.verify()
    }

    @Test func cacheDBFailure() async throws {
        let country = ApiModel.Country.mockedData[0].dbModel()
        let details = ApiModel.CountryDetails.mockedData[0]
        mockedWebRepo.actions = .init(expected: [
            .details(country: country),
        ])
        mockedWebRepo.detailsResponses = [.success(details)]
        mockedDBRepo.actions = .init(expected: [
            .fetchCountryDetails(country),
            .storeDetails(details, country: country),
            .fetchCountryDetails(country),
        ])
        let dbDetails = DBModel.CountryDetails(
            alpha3Code: country.alpha3Code,
            capital: details.capital,
            currencies: details.currencies.map({ $0.dbModel() }),
            neighbors: [])
        mockedDBRepo.countryDetailsResults = [
            .failure(NSError.test),
            .success(dbDetails)
        ]
        mockedDBRepo.storeCountryDetailsResults = [.success(())]
        let result = try await sut.loadCountryDetails(country: country, forceReload: false)
        #expect(result == dbDetails)
        mockedWebRepo.verify()
        mockedDBRepo.verify()
    }

    @Test func fetchAfterStoringDBFailure() async throws {
        let country = ApiModel.Country.mockedData[0].dbModel()
        let details = ApiModel.CountryDetails.mockedData[0]
        mockedWebRepo.actions = .init(expected: [
            .details(country: country),
        ])
        mockedWebRepo.detailsResponses = [.success(details)]
        mockedDBRepo.actions = .init(expected: [
            .fetchCountryDetails(country),
            .storeDetails(details, country: country),
            .fetchCountryDetails(country),
        ])
        let error = NSError.test
        mockedDBRepo.countryDetailsResults = [
            .success(nil),
            .failure(error)
        ]
        mockedDBRepo.storeCountryDetailsResults = [.success(())]
        await #expect(throws: ValueIsMissingError.self) {
            try await sut.loadCountryDetails(country: country, forceReload: false)
        }
        mockedWebRepo.verify()
        mockedDBRepo.verify()
    }

    @Test func storingDBFailure() async throws {
        let country = ApiModel.Country.mockedData[0].dbModel()
        let details = ApiModel.CountryDetails.mockedData[0]
        mockedWebRepo.actions = .init(expected: [
            .details(country: country),
        ])
        mockedWebRepo.detailsResponses = [.success(details)]
        mockedDBRepo.actions = .init(expected: [
            .fetchCountryDetails(country),
            .storeDetails(details, country: country),
        ])
        let error = NSError.test
        mockedDBRepo.countryDetailsResults = [.success(nil)]
        mockedDBRepo.storeCountryDetailsResults = [.failure(error)]
        await #expect(throws: error) {
            try await sut.loadCountryDetails(country: country, forceReload: false)
        }
        mockedWebRepo.verify()
        mockedDBRepo.verify()
    }

    @Test func webFailure() async throws {
        let country = ApiModel.Country.mockedData[0].dbModel()
        let error = NSError.test
        mockedWebRepo.actions = .init(expected: [
            .details(country: country),
        ])
        mockedWebRepo.detailsResponses = [.failure(error)]
        mockedDBRepo.actions = .init(expected: [
            .fetchCountryDetails(country),
        ])
        mockedDBRepo.countryDetailsResults = [.success(nil)]
        await #expect(throws: error) {
            try await sut.loadCountryDetails(country: country, forceReload: false)
        }
        mockedWebRepo.verify()
        mockedDBRepo.verify()
    }
}

final class StubCountriesInteractorTests: CountriesInteractorTests {

    @Test func stubInteractor() async throws {
        let country = ApiModel.Country.mockedData[0].dbModel()
        let sut = StubCountriesInteractor()
        try await sut.refreshCountriesList()
        await #expect(throws: ValueIsMissingError.self) {
            try await sut.loadCountryDetails(country: country, forceReload: false)
        }
    }
}
