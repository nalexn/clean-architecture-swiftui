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
    
    var appState: AppState!
    var sut: CountriesWebRepository!
    
    typealias API = RealCountriesWebRepository.API
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        appState = AppState()
        sut = RealCountriesWebRepository(session: .mockedResponsesOnly,
                                         baseURL: "https://test.com",
                                         appState: appState)
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
                XCTAssertEqual(self.appState, AppState())
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1)
        } catch let error { XCTFail("\(error)") }
    }
    
    func test_countryDetails() {
        do {
            let referenceAppState = AppState()
            let countries = Country.mockedData
            [appState, referenceAppState].forEach {
                $0.userData.countries = .loaded(countries)
            }
            let data = Country.Details.Intermediate(
                capital: "London",
                currencies: [Country.Currency(code: "12", symbol: "$", name: "US dollar")],
                borders: countries.map({ $0.alpha3Code }))
            let expected = Country.Details(capital: data.capital,
                                           currencies: data.currencies,
                                           neighbors: countries)
            try mock(.countryDetails(countries[0]), result: .success([data]))
            let exp = XCTestExpectation(description: "Completion")
            _ = sut.loadCountryDetails(country: countries[0]).sinkResult { result in
                result.assertSuccess(value: expected)
                XCTAssertEqual(self.appState, referenceAppState)
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1)
        } catch let error { XCTFail("\(error)") }
    }
    
    // MARK: - Helper
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>, httpCode: HTTPCode = 200) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result, httpCode: httpCode)
        RequestMocking.add(mock: mock)
    }
}
