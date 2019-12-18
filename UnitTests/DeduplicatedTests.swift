//
//  DeduplicatedTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 18.12.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import Combine
@testable import CountriesSwiftUI

class DeduplicatedTests: XCTestCase {
    
    private var subscriptions = Set<AnyCancellable>()
    
    override func setUp() {
        subscriptions.removeAll()
    }
    
    func test_deduplicated_noUpdateWhenCreated() {
        let exp = XCTestExpectation(description: "deduplicated")
        exp.isInverted = true
        let sut = TestObject()
            .deduplicated { TestObject.OneValueSnapshot(value1: $0.value1) }
        sut.objectWillChange.sink { _ in
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_deduplicated_filterDuplicate() {
        let exp1 = XCTestExpectation(description: "deduplicated")
        exp1.isInverted = true
        let exp2 = XCTestExpectation(description: "original")
        let sut = TestObject()
            .deduplicated { TestObject.OneValueSnapshot(value1: $0.value1) }
        sut.objectWillChange.sink { _ in
            exp1.fulfill()
        }.store(in: &subscriptions)
        sut.original.$value2.sink { _ in
            exp2.fulfill()
        }.store(in: &subscriptions)
        sut.value2 = 9
        wait(for: [exp1, exp2], timeout: 0.1)
    }
    
    func test_deduplicated_multipleUpdates() {
        let exp = XCTestExpectation(description: "deduplicated")
        exp.expectedFulfillmentCount = 2
        exp.assertForOverFulfill = true
        let sut = TestObject()
            .deduplicated { TestObject.TwoValuesSnapshot(
                value1: $0.value1, value2: $0.value2) }
        sut.objectWillChange.sink { _ in
            exp.fulfill()
        }.store(in: &subscriptions)
        sut.value1 = 5
        sut.value2 = 6
        DispatchQueue.main.async {
            sut.value2 = 7
        }
        wait(for: [exp], timeout: 1)
    }
}

private class TestObject: ObservableObject {
    @Published var value1: Int = 0
    @Published var value2: Int = 0
}

extension TestObject {
    struct OneValueSnapshot: Equatable {
        let value1: Int
    }
    
    struct TwoValuesSnapshot: Equatable {
        let value1: Int
        let value2: Int
    }
}
