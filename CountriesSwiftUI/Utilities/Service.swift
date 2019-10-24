//
//  Service.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Foundation
import Combine

protocol Service {
    var session: URLSession { get }
    var baseURL: String { get }
}

extension Service {
    func call<Value>(endpoint: APICall, httpCodes: HTTPCodes = .success) -> AnyPublisher<Value, Error> where Value: Decodable {
        do {
            let request = try endpoint.urlRequest(baseURL: baseURL)
            return session
                .dataTaskPublisher(for: request)
                .requestJSON(httpCodes: httpCodes)
        } catch let error {
            return Fail<Value, Error>(error: error).eraseToAnyPublisher()
        }
    }
}

private extension URLSession.DataTaskPublisher {
    func requestJSON<Value>(httpCodes: HTTPCodes) -> AnyPublisher<Value, Error> where Value: Decodable {
        return tryMap({
                let code = ($0.1 as? HTTPURLResponse)?.statusCode ?? 200
                guard httpCodes.contains(code) else {
                    throw APICallError.httpCode(code)
                }
                return $0.0
            })
            .decode(type: Value.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Subscribers.Completion helper

extension Subscribers.Completion {
    var error: Error? {
        switch self {
        case .finished: return nil
        case let .failure(error): return error
        }
    }
}
