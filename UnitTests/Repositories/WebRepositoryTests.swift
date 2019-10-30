//
//  WebRepositoryTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 30.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import Combine
@testable import CountriesSwiftUI

class WebRepositoryTests: XCTestCase {
    
    fileprivate var sut: TestWebRepository!
    
    fileprivate typealias API = TestWebRepository.API
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        sut = TestWebRepository()
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    func test_success() {
        do {
            let data = TestWebRepository.TestData()
            try mock(.test, result: .success(data))
            let exp = XCTestExpectation(description: "Completion")
            _ = sut.load().sinkResult { result in
                result.assertSuccess(value: data)
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1)
        } catch let error { XCTFail("\(error)") }
    }
    
    func test_webRepository_parseError() {
        do {
            let data = Country.mockedData
            try mock(.test, result: .success(data))
            let exp = XCTestExpectation(description: "Completion")
            _ = sut.load().sinkResult { result in
                result.assertFailure("The data couldn’t be read because it isn’t in the correct format.")
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1)
        } catch let error { XCTFail("\(error)") }
    }
    
    func test_allCountries_httpCodeFailure() {
        do {
            let data = TestWebRepository.TestData()
            try mock(.test, result: .success(data), httpCode: 500)
            let exp = XCTestExpectation(description: "Completion")
            _ = sut.load().sinkResult { result in
                result.assertFailure("Unexpected HTTP code: 500")
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1)
        } catch let error { XCTFail("\(error)") }
    }
    
    func test_allCountries_networkingError() {
        do {
            let error = NSError(domain: "test", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "test error"
            ])
            try mock(.test, result: Result<TestWebRepository.TestData, Error>.failure(error))
            let exp = XCTestExpectation(description: "Completion")
            _ = sut.load().sinkResult { result in
                result.assertFailure(error.localizedDescription)
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

private struct TestWebRepository: WebRepository {
    
    let session: URLSession = .mockedResponsesOnly
    let baseURL = "https://test.com"
    let bgQueue = DispatchQueue(label: "test")
    
    func load() -> AnyPublisher<TestData, Error> {
        call(endpoint: API.test)
    }
}

extension TestWebRepository {
    enum API: APICall {
        
        case test
        
        var path: String { "/test/path" }
        var method: String { "POST" }
        var headers: [String : String]? { nil }
        func body() throws -> Data? { nil }
    }
    
    struct TestData: Codable, Equatable {
        let string: String
        let integer: Int
        
        init() {
            string = "some string"
            integer = 42
        }
    }
}
