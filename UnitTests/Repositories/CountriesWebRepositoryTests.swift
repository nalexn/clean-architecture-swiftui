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
    private let baseURL = "https://test.com"
    
    typealias API = RealCountriesWebRepository.API
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        appState = AppState()
        sut = RealCountriesWebRepository(session: .mockedResponsesOnly,
                                         baseURL: baseURL,
                                         appState: appState)
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }

    func test_allCountries_success() {
        do {
            let data = Country.mockedData
            try mock(.allCountries, result: .success(data))
            let exp = XCTestExpectation(description: "Completion")
            _ = sut.loadCountries().sinkResult { result in
                result.assertSuccess(value: data)
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1)
        } catch let error { XCTFail("\(error)") }
    }
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>, httpCode: HTTPCode = 200) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: baseURL, result: result, httpCode: httpCode)
        RequestMocking.add(mock: mock)
    }
}
