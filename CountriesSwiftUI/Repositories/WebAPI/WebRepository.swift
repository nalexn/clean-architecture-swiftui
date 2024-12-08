//
//  WebRepository.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Foundation
import Combine

enum ApiModel { }

protocol WebRepository {
    var session: URLSession { get }
    var baseURL: String { get }
}

extension WebRepository {
    func call<Value, Decoder>(
        endpoint: APICall,
        decoder: Decoder = JSONDecoder(),
        httpCodes: HTTPCodes = .success
    ) async throws -> Value
    where Value: Decodable, Decoder: TopLevelDecoder, Decoder.Input == Data {

        let request = try endpoint.urlRequest(baseURL: baseURL)
        let (data, response) = try await session.data(for: request)
        guard let code = (response as? HTTPURLResponse)?.statusCode else {
            throw APIError.unexpectedResponse
        }
        guard httpCodes.contains(code) else {
            throw APIError.httpCode(code)
        }
        do {
            return try decoder.decode(Value.self, from: data)
        } catch {
            throw APIError.unexpectedResponse
        }
    }
}

// MARK: - APICall

protocol APICall {
    var path: String { get }
    var method: String { get }
    var headers: [String: String]? { get }
    func body() throws -> Data?
}

enum APIError: Swift.Error, Equatable {
    case invalidURL
    case httpCode(HTTPCode)
    case unexpectedResponse
    case imageDeserialization
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case let .httpCode(code): return "Unexpected HTTP code: \(code)"
        case .unexpectedResponse: return "Unexpected response from the server"
        case .imageDeserialization: return "Cannot deserialize image from Data"
        }
    }
}

extension APICall {
    func urlRequest(baseURL: String) throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = try body()
        return request
    }
}

typealias HTTPCode = Int
typealias HTTPCodes = Range<HTTPCode>

extension HTTPCodes {
    static let success = 200 ..< 300
}
