//
//  CountryDetailsTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 01.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import ViewInspector
@testable import CountriesSwiftUI

extension CountryDetails: Inspectable { }
extension DetailRow: Inspectable { }

class CountryDetailsTests: XCTestCase {
    
    let country = Country.mockedData[0]

    func test_details_notRequested() {
        let interactors = DIContainer.Interactors.mocked(
            countriesInteractor: [.loadCountryDetails(country)]
        )
        let exp = XCTestExpectation(description: #function)
        exp.expectedFulfillmentCount = 1
        exp.assertForOverFulfill = true
        var sut = CountryDetails(country: country, details: .notRequested)
        sut.didUpdate = { view in
            view.inspect { view in
                XCTAssertNoThrow(try view.content().text())
            }
            interactors.asyncVerify(exp)
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_isLoading_initial() {
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: #function)
        var sut = CountryDetails(country: country, details: .isLoading(last: nil))
        exp.expectedFulfillmentCount = 1
        exp.assertForOverFulfill = true
        sut.didUpdate = { view in
            view.inspect { view in
                XCTAssertNoThrow(try view.content().view(ActivityIndicatorView.self))
            }
            interactors.asyncVerify(exp)
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_isLoading_refresh() {
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: #function)
        exp.expectedFulfillmentCount = 1
        exp.assertForOverFulfill = true
        var sut = CountryDetails(country: country, details:
            .isLoading(last: Country.Details.mockedData[0])
        )
        sut.didUpdate = { view in
            view.inspect { view in
                XCTAssertNoThrow(try view.content().view(ActivityIndicatorView.self))
            }
            interactors.asyncVerify(exp)
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_loaded() {
        let interactors = DIContainer.Interactors.mocked(
            imagesInteractor: [.loadImage(country.flag)]
        )
        let exp = XCTestExpectation(description: #function)
        exp.expectedFulfillmentCount = 1
        exp.assertForOverFulfill = true
        var sut = CountryDetails(country: country, details:
            .loaded(Country.Details.mockedData[0])
        )
        sut.didUpdate = { view in
            view.inspect { view in
                let list = try view.content().list()
                XCTAssertNoThrow(try list.hStack(0).view(SVGImageView.self, 1))
                let countryCode = try list.section(1).view(DetailRow.self, 0)
                    .hStack().text(0).string()
                XCTAssertEqual(countryCode, self.country.alpha3Code)
            }
            interactors.asyncVerify(exp)
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 3)
    }
    
    func test_details_failed() {
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: #function)
        exp.expectedFulfillmentCount = 1
        exp.assertForOverFulfill = true
        var sut = CountryDetails(country: country, details: .failed(NSError.test))
        sut.didUpdate = { view in
            view.inspect { view in
                XCTAssertNoThrow(try view.content().view(ErrorView.self))
            }
            interactors.asyncVerify(exp)
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_failed_retry() {
        let interactors = DIContainer.Interactors.mocked(
            countriesInteractor: [.loadCountryDetails(country)]
        )
        let exp = XCTestExpectation(description: #function)
        exp.expectedFulfillmentCount = 1
        exp.assertForOverFulfill = true
        var sut = CountryDetails(country: country, details: .failed(NSError.test))
        sut.didUpdate = { view in
            view.inspect { view in
                let errorView = try view.content().view(ErrorView.self)
                try errorView.vStack().button(2).tap()
            }
            interactors.asyncVerify(exp)
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_sheetPresentation() {
        let interactors = DIContainer.Interactors.mocked(
            // Image is requested by CountryDetails and Details sheet:
            imagesInteractor: [.loadImage(country.flag),
                               .loadImage(country.flag)]
        )
        let container = DIContainer(appState: .init(AppState()), interactors: interactors)
        XCTAssertFalse(container.appState.value.routing.countryDetails.detailsSheet)
        let exp = XCTestExpectation(description: #function)
        exp.expectedFulfillmentCount = 2
        exp.assertForOverFulfill = true
        var sut = CountryDetails(country: country, details: .loaded(Country.Details.mockedData[0]))
        var updateNumber = 0
        sut.didUpdate = { view in
            updateNumber += 1
            if updateNumber == 1 {
                view.inspect { view in
                    try view.content().list().hStack(0).view(SVGImageView.self, 1).callOnTapGesture()
                }
            }
            if updateNumber == 2 {
                XCTAssertTrue(container.appState.value.routing.countryDetails.detailsSheet)
                interactors.asyncVerify(exp)
            } else {
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut.inject(container))
        wait(for: [exp], timeout: 2)
    }
}

// MARK: - CountryDetails inspection helper

extension InspectableView where View == ViewType.View<CountryDetails> {
    func content() throws -> InspectableView<ViewType.AnyView> {
        return try anyView()
    }
}
