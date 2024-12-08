//
//  RequestMocking.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 30.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Foundation

extension URLSession {
    static var mockedResponsesOnly: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [RequestMocking.self, RequestBlocking.self]
        configuration.timeoutIntervalForRequest = 1
        configuration.timeoutIntervalForResource = 1
        return URLSession(configuration: configuration)
    }
}

extension RequestMocking {
    private final class MocksContainer: @unchecked Sendable {
        var mocks: [MockedResponse] = []
    }
    static private let container = MocksContainer()
    static private let lock = NSLock()

    static func add(mock: MockedResponse) {
        lock.withLock {
            container.mocks.append(mock)
        }
    }
    
    static func removeAllMocks() {
        lock.withLock {
            container.mocks.removeAll()
        }
    }
    
    static private func mock(for request: URLRequest) -> MockedResponse? {
        return lock.withLock {
            container.mocks.first { $0.url == request.url }
        }
    }
}

// MARK: - RequestMocking

final class RequestMocking: URLProtocol {

    override class func canInit(with request: URLRequest) -> Bool {
        return mock(for: request) != nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    // swiftlint:disable identifier_name
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
    // swiftlint:enable identifier_name
        return false
    }

    override func startLoading() {
        if let mock = RequestMocking.mock(for: request),
            let url = request.url,
            let response = mock.customResponse ??
                HTTPURLResponse(url: url,
                statusCode: mock.httpCode,
                httpVersion: "HTTP/1.1",
                headerFields: mock.headers) {
            DispatchQueue.main.asyncAfter(deadline: .now() + mock.loadingTime) { [weak self] in
                guard let self else { return }
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                switch mock.result {
                case let .success(data):
                    self.client?.urlProtocol(self, didLoad: data)
                    self.client?.urlProtocolDidFinishLoading(self)
                case let .failure(error):
                    self.client?.urlProtocol(self, didFailWithError: error)
                }
            }
        }
    }

    override func stopLoading() { }
}

// MARK: - RequestBlocking

private class RequestBlocking: URLProtocol {
    enum Error: Swift.Error {
        case requestBlocked
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        DispatchQueue(label: "").async {
            self.client?.urlProtocol(self, didFailWithError: Error.requestBlocked)
        }
    }
    override func stopLoading() { }
}
