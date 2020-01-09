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
extension SVGImageView: Inspectable { }
extension DetailRow: Inspectable { }

class CountryDetailsTests: XCTestCase {
    
    let country = Country.mockedData[0]

    func test_details_notRequested() {
        let interactors = DIContainer.Interactors.mocked(
            countriesInteractor: [.loadCountryDetails(country)]
        )
        let exp = XCTestExpectation(description: "onAppear")
        var sut = CountryDetails(country: country, details: .notRequested)
        sut.didAppear = { view in
            view.inspectContent { content in
                XCTAssertNoThrow(try content.text())
            }
            interactors.asyncVerify(exp)
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_isLoading_initial() {
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        var sut = CountryDetails(country: country, details: .isLoading(last: nil))
        sut.didAppear = { view in
            view.inspectContent { content in
                XCTAssertNoThrow(try content.view(ActivityIndicatorView.self))
            }
            interactors.asyncVerify(exp)
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_isLoading_refresh() {
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        var sut = CountryDetails(country: country, details:
            .isLoading(last: Country.Details.mockedData[0])
        )
        sut.didAppear = { view in
            view.inspectContent { content in
                XCTAssertNoThrow(try content.view(ActivityIndicatorView.self))
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
        let exp = XCTestExpectation(description: "onAppear")
        var sut = CountryDetails(country: country, details:
            .loaded(Country.Details.mockedData[0])
        )
        sut.didAppear = { view in
            view.inspectContent { content in
                let list = try content.list()
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
        let exp = XCTestExpectation(description: "onAppear")
        var sut = CountryDetails(country: country, details: .failed(NSError.test))
        sut.didAppear = { view in
            view.inspectContent { content in
                XCTAssertNoThrow(try content.view(ErrorView.self))
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
        let exp = XCTestExpectation(description: "onAppear")
        var sut = CountryDetails(country: country, details: .failed(NSError.test))
        var isFirstUpdate = true
        sut.didAppear = { view in
            guard isFirstUpdate
                else { return } // Skip the update after triggering the refresh
            isFirstUpdate = false
            view.inspectContent { content in
                let errorView = try content.view(ErrorView.self)
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
        let exp = XCTestExpectation(description: "onAppear")
        var sut = CountryDetails(country: country, details: .loaded(Country.Details.mockedData[0]))
        sut.didAppear = { view in
            view.inspectContent { content in
                try content.list().hStack(0).view(SVGImageView.self, 1).callOnTapGesture()
            }
            XCTAssertTrue(container.appState.value.routing.countryDetails.detailsSheet)
            interactors.asyncVerify(exp)
        }
        ViewHosting.host(view: sut.inject(container))
        wait(for: [exp], timeout: 2)
    }
}

// MARK: - CountryDetails inspection helpers

private extension CountryDetails {
    
    func inspectContent(file: StaticString = #file, line: UInt = #line,
                        traverse: (InspectableView<ViewType.AnyView>) throws -> Void) {
        do {
            let content = try inspect().anyView()
            try traverse(content)
        } catch let error {
            XCTFail("\(error.localizedDescription)", file: file, line: line)
        }
    }
}
