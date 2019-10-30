//
//  MockedResponse.swift
//  UnitTests
//
//  Created by Alexey Naumov on 30.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Foundation
@testable import CountriesSwiftUI

extension RequestMocking {
    struct MockedResponse {
        let url: URL
        let result: Result<Data, Error>
        let httpCode: HTTPCode
        var headers: [String: String] = ["Content-Type": "application/json"]
        var loadingTime: TimeInterval = 0.1
    }
}

extension RequestMocking.MockedResponse {
    enum Error: Swift.Error {
        case failedMockCreation
    }
    
    init<T>(apiCall: APICall, baseURL: String,
            result: Result<T, Error>,
            httpCode: HTTPCode = HTTPCodes.success[0]) throws where T: Encodable {
        guard let url = try apiCall.urlRequest(baseURL: baseURL).url
            else { throw Error.failedMockCreation }
        self.url = url
        switch result {
        case let .success(value):
            self.result = .success(try JSONEncoder().encode(value))
        case let .failure(error):
            self.result = .failure(error)
        }
        self.httpCode = httpCode
    }
}
