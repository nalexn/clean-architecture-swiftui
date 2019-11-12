//
//  CountriesWebRepositoryTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 30.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
@testable import CountriesSwiftUI

class CountriesWebRepositoryTests: XCTestCase {
    
    var sut: RealCountriesWebRepository!
    
    typealias API = RealCountriesWebRepository.API
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        sut = RealCountriesWebRepository(session: .mockedResponsesOnly,
                                         baseURL: "https://test.com")
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    // MARK: - All Countries

    func test_allCountries() throws {
        let data = Country.mockedData
        try mock(.allCountries, result: .success(data))
        let exp = XCTestExpectation(description: "Completion")
        _ = sut.loadCountries().sinkToResult { result in
            result.assertSuccess(value: data)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2)
    }
    
    func test_countryDetails() throws {
        let countries = Country.mockedData
        let value = Country.Details.Intermediate(
            capital: "London",
            currencies: [Country.Currency(code: "12", symbol: "$", name: "US dollar")],
            borders: countries.map({ $0.alpha3Code }))
        try mock(.countryDetails(countries[0]), result: .success([value]))
        let exp = XCTestExpectation(description: "Completion")
        _ = sut.loadCountryDetails(country: countries[0]).sinkToResult { result in
            result.assertSuccess(value: value)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2)
    }
    
    func test_countryDetails_whenDetailsAreEmpty() throws {
        let countries = Country.mockedData
        try mock(.countryDetails(countries[0]), result: .success([Country.Details.Intermediate]()))
        let exp = XCTestExpectation(description: "Completion")
        _ = sut.loadCountryDetails(country: countries[0]).sinkToResult { result in
            result.assertFailure(APIError.unexpectedResponse.localizedDescription)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2)
    }
    
    func test_countryDetails_countryNameEncoding() {
        let name = String(bytes: [0xD8, 0x00] as [UInt8], encoding: .utf16BigEndian)!
        let country = Country(name: name, population: 1, flag: nil, alpha3Code: "ABC")
        let apiCall = RealCountriesWebRepository.API.countryDetails(country)
        XCTAssertTrue(apiCall.path.hasSuffix(name))
    }
    
    // MARK: - Helper
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>, httpCode: HTTPCode = 200) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result, httpCode: httpCode)
        RequestMocking.add(mock: mock)
    }
}
