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
import ViewInspector
@testable import CountriesSwiftUI

// MARK: - UI

extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { rendererContext in
            setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}

// MARK: - Result

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

extension Result {
    func publish() -> AnyPublisher<Success, Failure> {
        return publisher
            .delay(for: .milliseconds(10), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - XCTestCase

func XCTAssertEqual<T>(_ expression1: @autoclosure () throws -> T,
                       _ expression2: @autoclosure () throws -> T,
                       removing prefixes: [String],
                       file: StaticString = #file, line: UInt = #line) where T: Equatable {
    do {
        let exp1 = try expression1()
        let exp2 = try expression2()
        if exp1 != exp2 {
            let desc1 = prefixes.reduce(String(describing: exp1), { (str, prefix) in
                str.replacingOccurrences(of: prefix, with: "")
            })
            let desc2 = prefixes.reduce(String(describing: exp2), { (str, prefix) in
                str.replacingOccurrences(of: prefix, with: "")
            })
            XCTFail("XCTAssertEqual failed:\n\n\(desc1)\n\nis not equal to\n\n\(desc2)", file: file, line: line)
        }
    } catch {
        XCTFail("Unexpected exception: \(error)")
    }
}

protocol PrefixRemovable { }

extension PrefixRemovable {
    static var prefixes: [String] {
        let name = String(reflecting: Self.self)
        var components = name.components(separatedBy: ".")
        let module = components.removeFirst()
        let fullTypeName = components.joined(separator: ".")
        return [
            "\(module).",
            "Loadable<\(fullTypeName)>",
            "Loadable<LazyList<\(fullTypeName)>>"
        ]
    }
}

// MARK: - BindingWithPublisher

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

// MARK: - Error

enum MockError: Swift.Error {
    case valueNotSet
}

extension NSError {
    static var test: NSError {
        return NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Test error"])
    }
}

extension Inspection: InspectionEmissary where V: Inspectable { }
