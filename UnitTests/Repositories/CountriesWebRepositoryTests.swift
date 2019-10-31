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
                                         baseURL: "https://test.com",
                                         appState: AppState())
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    // MARK: - All Countries

    func test_allCountries() {
        do {
            let data = Country.mockedData
            try mock(.allCountries, result: .success(data))
            let exp = XCTestExpectation(description: "Completion")
            _ = sut.loadCountries().sinkResult { result in
                result.assertSuccess(value: data)
                XCTAssertEqual(self.sut.appState, AppState())
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1)
        } catch let error { XCTFail("\(error)") }
    }
    
    func test_countryDetails() {
        do {
            let countries = Country.mockedData
            let value = Country.Details.Intermediate(
                capital: "London",
                currencies: [Country.Currency(code: "12", symbol: "$", name: "US dollar")],
                borders: countries.map({ $0.alpha3Code }))
            try mock(.countryDetails(countries[0]), result: .success([value]))
            let exp = XCTestExpectation(description: "Completion")
            _ = sut.loadCountryDetails(country: countries[0]).sinkResult { result in
                result.assertSuccess(value: value)
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1)
        } catch let error { XCTFail("\(error)") }
    }
    
    func test_countryDetails_whenDetailsAreEmpty() {
        do {
            let countries = Country.mockedData
            try mock(.countryDetails(countries[0]), result: .success([Country.Details.Intermediate]()))
            let exp = XCTestExpectation(description: "Completion")
            _ = sut.loadCountryDetails(country: countries[0]).sinkResult { result in
                result.assertFailure(APIError.unexpectedResponse.localizedDescription)
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1)
        } catch let error { XCTFail("\(error)") }
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
