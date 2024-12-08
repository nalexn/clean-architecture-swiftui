//
//  CountriesDBRepositoryTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 19.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import Testing
import SwiftData
@testable import CountriesSwiftUI

@MainActor
@Suite struct CountriesDBRepositoryTests {

    let container: ModelContainer
    let sut: CountriesDBRepository

    init() {
        container = .mock
        sut = MainDBRepository(modelContainer: container)
    }

    @Test func storeCountries() async throws {
        let countries = ApiModel.Country.mockedData
        try await sut.store(countries: countries)
        let results = try container.mainContext
            .fetch(FetchDescriptor<DBModel.Country>())
        #expect(results.count == countries.count)
    }

    @Test func storeCountryDetails() async throws {
        let country = ApiModel.Country.mockedData[0]
        let details = ApiModel.CountryDetails.mockedData[0]
        try await sut.store(countryDetails: details, for: country.dbModel())
        let results = try container.mainContext
            .fetch(FetchDescriptor<DBModel.CountryDetails>())
        let stored = try #require(results.first)
        #expect(stored.capital == details.capital)
        #expect(stored.currencies.count == details.currencies.count)
    }

    @Test func countryDetailsForCountry() async throws {
        let country = ApiModel.Country.mockedData[0].dbModel()
        let details = ApiModel.CountryDetails.mockedData[0]
        try await sut.store(countryDetails: details, for: country)
        let stored = try #require(try await sut.countryDetails(for: country))
        #expect(stored.capital == details.capital)
        #expect(stored.currencies.count == details.currencies.count)
    }
}

