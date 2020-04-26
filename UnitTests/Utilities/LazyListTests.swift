//
//  LazyListTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 18.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import XCTest
import Combine
@testable import CountriesSwiftUI

final class LazyListTests: XCTestCase {

    func test_empty() {
        let list = LazyList<Int>.empty
        XCTAssertThrowsError(try list.element(at: 0))
    }
    
    func test_nil_element() {
        let list1 = LazyList<Int>(count: 1, useCache: false, { _ in nil })
        XCTAssertThrowsError(try list1.element(at: 0))
        let list2 = [0, 1].lazyList
        XCTAssertThrowsError(try list2.element(at: 2))
    }
    
    func test_nil_element_error() {
        let error = LazyList<Int>.Error.elementIsNil(index: 5)
        XCTAssertEqual(error.localizedDescription, "Element at index 5 is nil")
    }
    
    func test_access_noCache() {
        var counter = 0
        let list = LazyList<Int>(count: 3, useCache: false) { _ in
            counter += 1
            return counter
        }
        [0, 1, 2, 0, 1, 2].forEach { index in
            _ = list[index]
        }
        XCTAssertEqual(counter, 6)
    }
    
    func test_access_withCache() {
        var counter = 0
        let list = LazyList<Int>(count: 3, useCache: true) { _ in
            counter += 1
            return counter
        }
        [0, 1, 2, 0, 1, 2].forEach { index in
            _ = list[index]
        }
        XCTAssertEqual(counter, 3)
    }
    
    let bgQueue1 = DispatchQueue(label: "bg1")
    let bgQueue2 = DispatchQueue(label: "bg2")
    
    func test_concurrent_access() {
        let indices = Array(stride(from: 0, to: 100, by: 1))
        var counter = 0
        let list = LazyList<Int>(count: indices.count, useCache: true) { index in
            counter += 1
            return index
        }
        let exp1 = XCTestExpectation(description: "queue1")
        let exp2 = XCTestExpectation(description: "queue2")
        bgQueue1.async {
            let result1 = indices.map { list[$0] }
            XCTAssertEqual(result1, indices)
            XCTAssertEqual(counter, indices.count)
            exp1.fulfill()
        }
        bgQueue2.async {
            let result2 = indices.map { list[$0] }
            XCTAssertEqual(result2, indices)
            XCTAssertEqual(counter, indices.count)
            exp2.fulfill()
        }
        wait(for: [exp1, exp2], timeout: 0.5)
    }
    
    func test_sequence() {
        let indices = Array(stride(from: 0, to: 10, by: 1))
        let list = LazyList<Int>(count: indices.count, useCache: true) { $0 }
        XCTAssertEqual(list.underestimatedCount, indices.count)
        XCTAssertEqual(list.reversed(), indices.reversed())
        
        let nilList = LazyList<Int>(count: 1, useCache: false) { _ in nil }
        var iterator = nilList.makeIterator()
        XCTAssertNil(iterator.next())
    }
    
    func test_randomAccessCollection() {
        let list = LazyList<Int>(count: 10, useCache: true) { $0 }
        XCTAssertEqual(list.firstIndex(of: 2), 2)
        XCTAssertEqual(list.last, 9)
    }
    
    func test_equatable() {
        let list1 = LazyList<Int>(count: 10, useCache: true) { $0 }
        let list2 = LazyList<Int>(count: 11, useCache: true) { $0 }
        let list3 = Array(stride(from: 0, to: 10, by: 1)).lazyList
        XCTAssertNotEqual(list1, list2)
        XCTAssertEqual(list1, list1)
        XCTAssertEqual(list1, list3)
    }
    
    func test_description() {
        let emptyList = LazyList<Int>.empty
        let oneElementList = LazyList<Int>(count: 1, useCache: false) { $0 + 1 }
        let nonEmptyList = LazyList<Int>(count: 3, useCache: false) { $0 * 2 }
        XCTAssertEqual(emptyList.description, "LazyList<[]>")
        XCTAssertEqual(oneElementList.description, "LazyList<[1]>")
        XCTAssertEqual(nonEmptyList.description, "LazyList<[0, 2, 4]>")
    }
}
