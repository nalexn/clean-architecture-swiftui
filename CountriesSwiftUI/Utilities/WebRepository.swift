//
//  WebRepository.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Foundation
import Combine

protocol WebRepository {
    var session: URLSession { get }
    var baseURL: String { get }
    var bgQueue: DispatchQueue { get }
}

extension WebRepository {
    func call<Value>(endpoint: APICall, httpCodes: HTTPCodes = .success) -> AnyPublisher<Value, Error>
        where Value: Decodable {
        do {
            let request = try endpoint.urlRequest(baseURL: baseURL)
            return session
                .dataTaskPublisher(for: request)
                .requestJSON(httpCodes: httpCodes)
                .ensureTimeSpan(0.5) // Hold the response if it arrives too quickly
        } catch let error {
            return Fail<Value, Error>(error: error).eraseToAnyPublisher()
        }
    }
}

// MARK: - Helpers

private extension Publisher where Output == URLSession.DataTaskPublisher.Output {
    func requestJSON<Value>(httpCodes: HTTPCodes) -> AnyPublisher<Value, Error> where Value: Decodable {
        return tryMap {
                assert(!Thread.isMainThread)
                guard let code = ($0.1 as? HTTPURLResponse)?.statusCode else {
                    throw APIError.unexpectedResponse
                }
                guard httpCodes.contains(code) else {
                    throw APIError.httpCode(code)
                }
                return $0.0
            }
            .extractUnderlyingError()
            .decode(type: Value.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

private extension Publisher {
    
    /// Holds the downstream delivery of output until the specified time interval passed after the subscription
    /// Does not hold the output if it arrives later than the time threshold
    ///
    /// - Parameters:
    ///   - interval: The minimum time interval that should elapse after the subscription.
    /// - Returns: A publisher that optionally delays delivery of elements to the downstream receiver.
    
    func ensureTimeSpan(_ interval: TimeInterval) -> AnyPublisher<Output, Failure> {
        let timer = Just<Void>(())
            .delay(for: .seconds(interval), scheduler: RunLoop.main)
            .setFailureType(to: Failure.self)
        return zip(timer)
            .map { $0.0 }
            .eraseToAnyPublisher()
    }
}
