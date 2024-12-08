//
//  CountriesWebRepositoryTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 30.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Testing
@testable import CountriesSwiftUI

@Suite(.serialized) final class CountriesWebRepositoryTests {

    private let sut = RealCountriesWebRepository(session: .mockedResponsesOnly)

    typealias API = RealCountriesWebRepository.API
    typealias Mock = RequestMocking.MockedResponse

    deinit {
        RequestMocking.removeAllMocks()
    }

    // MARK: - All Countries

    @Test func allCountriesSuccess() async throws {
        let data = await ApiModel.Country.mockedData
        try mock(.allCountries, result: .success(data))
        let response = try await sut.countries()
        #expect(response == data)
    }

    @Test func countryDetailsSuccess() async throws {
        let countries = await ApiModel.Country.mockedData
        let value = ApiModel.CountryDetails(
            capital: "London",
            currencies: [ApiModel.Currency(code: "12", symbol: "$", name: "US dollar")],
            borders: countries.map({ $0.alpha3Code }))
        let country = countries[0]
        try mock(.countryDetails(countryName: country.name), result: .success([value]))
        let response = try await sut.details(country: country.dbModel())
        #expect(response == value)
    }

    @Test func countryDetailsWhenDetailsAreEmpty() async throws {
        let countries = await ApiModel.Country.mockedData
        let country = countries[0]
        try mock(.countryDetails(countryName: country.name), result: .success([ApiModel.CountryDetails]()))
        await #expect(throws: APIError.unexpectedResponse) {
            try await sut.details(country: country.dbModel())
        }
    }

    // MARK: - Helper

    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>,
                         httpCode: HTTPCode = 200) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result, httpCode: httpCode)
        RequestMocking.add(mock: mock)
    }
}

