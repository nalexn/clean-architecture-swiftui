//
//  CoreDataStackTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 19.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import XCTest
import Combine
@testable import CountriesSwiftUI

extension CoreDataStack.DBFileDirectory {
    static let testsURL = FileManager.default.temporaryDirectory.appendingPathComponent("tests")
    static var tests: CoreDataStack.DBFileDirectory {
        return .custom(testsURL)
    }
}

class CoreDataStackTests: XCTestCase {
    
    var sut: CoreDataStack!
    var dbVersion: UInt { fatalError("Override") }
    var cancelBag = CancelBag()
    
    override func setUp() {
        eraseDBFiles()
        sut = CoreDataStack(version: dbVersion, directory: .tests)
    }
    
    override func tearDown() {
        cancelBag = CancelBag()
        sut = nil
        eraseDBFiles()
    }
    
    func eraseDBFiles() {
        try? FileManager().removeItem(at: CoreDataStack.DBFileDirectory.testsURL)
    }
}

// MARK: - Version 1

class CoreDataStackV1Tests: CoreDataStackTests {
    
    override var dbVersion: UInt { 1 }

    func test_initialization() {
        let exp = XCTestExpectation(description: #function)
        let request = CountryMO.newFetchRequest()
        request.predicate = NSPredicate(value: true)
        request.fetchLimit = 1
        sut.fetch(request) { _ -> Int? in
            return nil
        }
        .sinkToResult { result in
            result.assertSuccess(value: LazyList<Int>.empty)
            exp.fulfill()
        }
        .store(in: cancelBag)
        wait(for: [exp], timeout: 1)
    }
    
    func test_inaccessibleDirectory() {
        let inaccessibleURL = FileManager.default
            .urls(for: .adminApplicationDirectory, in: .systemDomainMask).first!
        let sut = CoreDataStack(version: dbVersion, directory: .custom(inaccessibleURL))
        let exp = XCTestExpectation(description: #function)
        let request = CountryMO.newFetchRequest()
        request.predicate = NSPredicate(value: true)
        request.fetchLimit = 1
        sut.fetch(request) { _ -> Int? in
            return nil
        }
        .sinkToResult { result in
            result.assertFailure()
            exp.fulfill()
        }
        .store(in: cancelBag)
        wait(for: [exp], timeout: 1)
    }
    
    func test_counting_onEmptyStore() {
        let request = CountryMO.newFetchRequest()
        request.predicate = NSPredicate(value: true)
        let exp = XCTestExpectation(description: #function)
        sut.count(request)
        .sinkToResult { result in
            result.assertSuccess(value: 0)
            exp.fulfill()
        }
        .store(in: cancelBag)
        wait(for: [exp], timeout: 1)
    }
    
    func test_storing_and_countring() {
        let countries = Country.mockedData
        
        let request = CountryMO.newFetchRequest()
        request.predicate = NSPredicate(value: true)
        
        let exp = XCTestExpectation(description: #function)
        sut.update { context in
            countries.forEach {
                $0.store(in: context)
            }
        }
        .flatMap { _ in
            self.sut.count(request)
        }
        .sinkToResult { result in
            result.assertSuccess(value: countries.count)
            exp.fulfill()
        }
        .store(in: cancelBag)
        wait(for: [exp], timeout: 1)
    }
    
    func test_storing_exception() {
        let exp = XCTestExpectation(description: #function)
        sut.update { context in
            throw NSError.test
        }
        .sinkToResult { result in
            result.assertFailure(NSError.test.localizedDescription)
            exp.fulfill()
        }
        .store(in: cancelBag)
        wait(for: [exp], timeout: 1)
    }
    
    func test_fetching() {
        let countries = Country.mockedData
        let exp = XCTestExpectation(description: #function)
        sut
            .update { context in
                countries.forEach {
                    $0.store(in: context)
                }
            }
            .flatMap { _ -> AnyPublisher<LazyList<Country>, Error> in
                let request = CountryMO.newFetchRequest()
                request.predicate = NSPredicate(format: "alpha3code == %@", countries[0].alpha3Code)
                return self.sut.fetch(request) {
                    Country(managedObject: $0)
                }
            }
            .sinkToResult { result in
                result.assertSuccess(value: LazyList<Country>(
                    count: 1, useCache: false, { _ in countries[0] })
                )
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 1)
    }
}

// MARK: - Version 2

final class CoreDataStackV2Tests: CoreDataStackV1Tests {
    
    override var dbVersion: UInt { 2 }
    
    func test_migration_from_v1() {
        sut = nil
        eraseDBFiles()
        var oldStack: CoreDataStack? = CoreDataStack(version: 1, directory: .tests)
        var newStack: CoreDataStack?
        let countries = Country.mockedData
        let exp = XCTestExpectation(description: #function)
        let fm = FileManager.default
        let oldURL = CoreDataStack.Version(1).dbFileURL(directory: .tests)!.path
        let newURL = CoreDataStack.Version(dbVersion).dbFileURL(directory: .tests)!.path
        oldStack!
            .update { context in
                countries.forEach { $0.store(in: context) }
            }
            .flatMap { _ -> AnyPublisher<Int, Error> in
                XCTAssertTrue(fm.fileExists(atPath: oldURL))
                newStack = CoreDataStack(version: self.dbVersion, directory: .tests)
                let request = CountryMO.newFetchRequest()
                request.predicate = NSPredicate(value: true)
                return newStack!.count(request)
            }
            .sinkToResult { result in
                result.assertSuccess(value: countries.count)
                XCTAssertFalse(fm.fileExists(atPath: oldURL))
                XCTAssertTrue(fm.fileExists(atPath: newURL))
                exp.fulfill()
                oldStack = nil
                newStack = nil
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 3)
    }
}
