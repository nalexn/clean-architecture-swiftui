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
    
    func test_webRepository_success() {
        do {
            let data = TestWebRepository.TestData()
            try mock(.test, result: .success(data))
            let exp = XCTestExpectation(description: "Completion")
            _ = sut.load(.test).sinkResult { result in
                XCTAssertTrue(Thread.isMainThread)
                result.assertSuccess(value: data)
                exp.fulfill()
            }
            wait(for: [exp], timeout: 2)
        } catch let error { XCTFail("\(error)") }
    }
    
    func test_webRepository_parseError() {
        do {
            let data = Country.mockedData
            try mock(.test, result: .success(data))
            let exp = XCTestExpectation(description: "Completion")
            _ = sut.load(.test).sinkResult { result in
                XCTAssertTrue(Thread.isMainThread)
                result.assertFailure("The data couldn’t be read because it isn’t in the correct format.")
                exp.fulfill()
            }
            wait(for: [exp], timeout: 2)
        } catch let error { XCTFail("\(error)") }
    }
    
    func test_webRepository_httpCodeFailure() {
        do {
            let data = TestWebRepository.TestData()
            try mock(.test, result: .success(data), httpCode: 500)
            let exp = XCTestExpectation(description: "Completion")
            _ = sut.load(.test).sinkResult { result in
                XCTAssertTrue(Thread.isMainThread)
                result.assertFailure("Unexpected HTTP code: 500")
                exp.fulfill()
            }
            wait(for: [exp], timeout: 2)
        } catch let error { XCTFail("\(error)") }
    }
    
    func test_webRepository_networkingError() {
        do {
            let error = NSError.test
            try mock(.test, result: Result<TestWebRepository.TestData, Error>.failure(error))
            let exp = XCTestExpectation(description: "Completion")
            _ = sut.load(.test).sinkResult { result in
                XCTAssertTrue(Thread.isMainThread)
                result.assertFailure(error.localizedDescription)
                exp.fulfill()
            }
            wait(for: [exp], timeout: 2)
        } catch let error { XCTFail("\(error)") }
    }
    
    func test_webRepository_requestURLError() {
        let exp = XCTestExpectation(description: "Completion")
        _ = sut.load(.urlError).sinkResult { result in
            XCTAssertTrue(Thread.isMainThread)
            result.assertFailure(APIError.invalidURL.localizedDescription)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2)
    }
    
    func test_webRepository_requestBodyError() {
        let exp = XCTestExpectation(description: "Completion")
        _ = sut.load(.bodyError).sinkResult { result in
            XCTAssertTrue(Thread.isMainThread)
            result.assertFailure(TestWebRepository.APIError.fail.localizedDescription)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2)
    }
    
    func test_webRepository_loadableError() {
        let exp = XCTestExpectation(description: "Completion")
        let expected = APIError.invalidURL.localizedDescription
        _ = sut.load(.urlError)
            .sinkToLoadable { loadable in
                XCTAssertTrue(Thread.isMainThread)
                XCTAssertEqual(loadable.error?.localizedDescription, expected)
                exp.fulfill()
            }
        wait(for: [exp], timeout: 2)
    }
    
    func test_webRepository_noHttpCodeError() {
        do {
            let response = URLResponse(url: URL(fileURLWithPath: ""),
                                       mimeType: "example", expectedContentLength: 0, textEncodingName: nil)
            let mock = try Mock(apiCall: API.test, baseURL: sut.baseURL, customResponse: response)
            RequestMocking.add(mock: mock)
            let exp = XCTestExpectation(description: "Completion")
            _ = sut.load(.test).sinkResult { result in
                XCTAssertTrue(Thread.isMainThread)
                result.assertFailure(APIError.unexpectedResponse.localizedDescription)
                exp.fulfill()
            }
            wait(for: [exp], timeout: 2)
        } catch let error { XCTFail("\(error)") }
    }
    
    // MARK: - Helper
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>, httpCode: HTTPCode = 200) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result, httpCode: httpCode)
        RequestMocking.add(mock: mock)
    }
}

private extension TestWebRepository {
    func load(_ api: API) -> AnyPublisher<TestData, Error> {
        call(endpoint: api)
    }
}

extension TestWebRepository {
    enum API: APICall {
        
        case test
        case urlError
        case bodyError
        case noHttpCodeError
        
        var path: String {
            if self == .urlError {
                return "😋😋😋"
            }
            return "/test/path"
        }
        var method: String { "POST" }
        var headers: [String : String]? { nil }
        func body() throws -> Data? {
            if self == .bodyError { throw APIError.fail }
            return nil
        }
    }
}

extension TestWebRepository {
    enum APIError: Swift.Error, LocalizedError {
        case fail
        var errorDescription: String? { "fail" }
    }
}

extension TestWebRepository {
    struct TestData: Codable, Equatable {
        let string: String
        let integer: Int
        
        init() {
            string = "some string"
            integer = 42
        }
    }
}
