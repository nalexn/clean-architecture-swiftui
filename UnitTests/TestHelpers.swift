//
//  TestHelpers.swift
//  UnitTests
//
//  Created by Alexey Naumov on 30.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import SwiftUI
import Combine

enum MockError: Swift.Error {
    case valueNotSet
}

extension Publisher {
    func sinkResult(_ result: @escaping (Result<Output, Failure>) -> Void) -> AnyCancellable {
        return sink(receiveCompletion: { completion in
            switch completion {
            case let .failure(error):
                result(.failure(error))
            default: break
            }
        }, receiveValue: { value in
            result(.success(value))
        })
    }
}

extension Result where Success: Equatable {
    func assertSuccess(value: Success, file: StaticString = #file, line: UInt = #line) {
        switch self {
        case let .success(resultValue):
            XCTAssertEqual(resultValue, value, file: file, line: line)
        case let .failure(error):
            XCTFail("Unexpected error: \(error)", file: file, line: line)
        }
    }
}

extension Result {
    func assertFailure(_ message: String, file: StaticString = #file, line: UInt = #line) {
        switch self {
        case let .success(value):
            XCTFail("Unexpected success: \(value)", file: file, line: line)
        case let .failure(error):
            XCTAssertEqual(error.localizedDescription, message, file: file, line: line)
        }
    }
}

struct BindingWithPublisher<Value> {
    
    let binding: Binding<Value>
    let updatesRecorder: AnyPublisher<[Value], Never>
    
    init(value: Value, recordingTimeInterval: TimeInterval = 0.5) {
        var value = value
        var updates = [value]
        binding = Binding<Value>(
            get: { value },
            set: { value = $0; updates.append($0) })
        updatesRecorder = Future<[Value], Never> { completion in
            DispatchQueue.main.asyncAfter(deadline: .now() + recordingTimeInterval) {
                completion(.success(updates))
            }
        }.eraseToAnyPublisher()
    }
}

extension NSError {
    static var test: NSError {
        return NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Test error"])
    }
}
