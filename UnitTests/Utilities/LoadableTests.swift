//
//  LoadableTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 31.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Foundation
import Testing
import Combine
import SwiftUI
import ViewInspector
@testable import CountriesSwiftUI

@Suite struct LoadableTests {

    @Test func equality() {
        let possibleValues: [Loadable<Int>] = [
            .notRequested,
            .isLoading(last: nil, cancelBag: CancelBag()),
            .isLoading(last: 9, cancelBag: CancelBag()),
            .loaded(5),
            .loaded(6),
            .failed(NSError.test)
        ]
        possibleValues.enumerated().forEach { (index1, value1) in
            possibleValues.enumerated().forEach { (index2, value2) in
                if index1 == index2 {
                    #expect(value1 == value2)
                } else {
                    #expect(value1 != value2)
                }
            }
        }
    }

    @Test func cancelLoading() {
        let cancenBag1 = CancelBag(), cancenBag2 = CancelBag()
        let subject = PassthroughSubject<Int, Never>()
        subject.sink { _ in }
            .store(in: cancenBag1)
        subject.sink { _ in }
            .store(in: cancenBag2)
        var sut1 = Loadable<Int>.isLoading(last: nil, cancelBag: cancenBag1)
        #expect(cancenBag1.subscriptions.count == 1)
        sut1.cancelLoading()
        #expect(cancenBag1.subscriptions.count == 0)
        #expect(sut1.error != nil)
        var sut2 = Loadable<Int>.isLoading(last: 7, cancelBag: cancenBag2)
        #expect(cancenBag2.subscriptions.count == 1)
        sut2.cancelLoading()
        #expect(cancenBag2.subscriptions.count == 0)
        #expect(sut2.value == 7)
    }

    @Test func map() {
        let values: [Loadable<Int>] = [
            .notRequested,
            .isLoading(last: nil, cancelBag: CancelBag()),
            .isLoading(last: 5, cancelBag: CancelBag()),
            .loaded(7),
            .failed(NSError.test)
        ]
        let expect: [Loadable<String>] = [
            .notRequested,
            .isLoading(last: nil, cancelBag: .test),
            .isLoading(last: "5", cancelBag: .test),
            .loaded("7"),
            .failed(NSError.test)
        ]
        let sut = values.map { value in
            value.map { "\($0)" }
        }
        #expect(sut == expect)
    }

    @MainActor
    @Test func loadSuccess() async {
        let resource: () async throws -> String = {
            try await Task.sleep(nanoseconds: 100_000_000)
            return "test"
        }
        let exp = TestExpectation()
        var values: [Loadable<String>] = []
        let sut = Binding<Loadable<String>>.init(get: {
            return values.last ?? .notRequested
        }, set: {
            values.append($0)
            if $0.value != nil {
                exp.fulfill()
            }
        })
        sut.load(resource)
        await exp.fulfillment()
        #expect(values == [.isLoading(last: nil, cancelBag: .test), .loaded("test")])
    }

    @MainActor
    @Test func loadFailure() async {
        let resource: () async throws -> String = {
            try await Task.sleep(nanoseconds: 100_000_000)
            throw NSError.test
        }
        let exp = TestExpectation()
        var values: [Loadable<String>] = []
        let sut = Binding<Loadable<String>>.init(get: {
            return values.last ?? .notRequested
        }, set: {
            values.append($0)
            if $0.error != nil {
                exp.fulfill()
            }
        })
        sut.load(resource)
        await exp.fulfillment()
        #expect(values == [.isLoading(last: nil, cancelBag: .test), .failed(NSError.test)])
    }

    @Test func helperFunctions() {
        let notRequested = Loadable<Int>.notRequested
        let loadingNil = Loadable<Int>.isLoading(last: nil, cancelBag: CancelBag())
        let loadingValue = Loadable<Int>.isLoading(last: 9, cancelBag: CancelBag())
        let loaded = Loadable<Int>.loaded(5)
        let failedErrValue = Loadable<Int>.failed(NSError.test)
        [notRequested, loadingNil].forEach {
            #expect($0.value == nil)
        }
        [loadingValue, loaded].forEach {
            #expect($0.value != nil)
        }
        [notRequested, loadingNil, loadingValue, loaded].forEach {
            #expect($0.error == nil)
        }
        #expect(failedErrValue.error != nil)
    }

    @Test func throwingMap() {
        let value = Loadable<Int>.loaded(5)
        let sut = value.map { _ in throw NSError.test }
        #expect(sut.error != nil)
    }

    @Test func valueIsMissing() {
        #expect(ValueIsMissingError().localizedDescription == "Data is missing")
    }
}
