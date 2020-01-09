//
//  CountriesListTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 01.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import ViewInspector
@testable import CountriesSwiftUI

extension CountriesList: Inspectable { }
extension ActivityIndicatorView: Inspectable { }
extension CountryCell: Inspectable { }
extension ErrorView: Inspectable { }

class CountriesListTests: XCTestCase {

    func test_countries_notRequested() {
        let appState = AppState()
        XCTAssertEqual(appState.userData.countries, .notRequested)
        let interactors = DIContainer.Interactors.mocked(
            countriesInteractor: [.loadCountries])
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountriesList(didSetCountries: { view in
            view.inspectContent { content in
                XCTAssertNoThrow(try content.text())
            }
            interactors.asyncVerify(exp)
        })
        ViewHosting.host(view: sut.inject(appState, interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_isLoading_initial() {
        var appState = AppState()
        let interactors = DIContainer.Interactors.mocked()
        appState.userData.countries = .isLoading(last: nil)
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountriesList(didSetCountries: { view in
            view.inspectContent { content in
                let vStack = try content.vStack()
                XCTAssertNoThrow(try vStack.view(ActivityIndicatorView.self, 0))
                XCTAssertThrowsError(try vStack.list(1))
            }
            interactors.asyncVerify(exp)
        })
        ViewHosting.host(view: sut.inject(appState, interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_isLoading_refresh() {
        var appState = AppState()
        appState.userData.countries = .isLoading(last: Country.mockedData)
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountriesList(didSetCountries: { view in
            view.inspectContent { content in
                let vStack = try content.vStack()
                XCTAssertNoThrow(try vStack.view(ActivityIndicatorView.self, 0))
                XCTAssertNoThrow(try vStack.list(1))
            }
            interactors.asyncVerify(exp)
        })
        ViewHosting.host(view: sut.inject(appState, interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_loaded() {
        var appState = AppState()
        appState.userData.countries = .loaded(Country.mockedData)
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountriesList(didSetCountries: { view in
            view.inspectContent { content in
                let cell = try content.list().forEach(0).hStack(0)
                    .navigationLink(0).label().view(CountryCell.self).actualView()
                XCTAssertEqual(cell.country, Country.mockedData[0])
            }
            interactors.asyncVerify(exp)
        })
        ViewHosting.host(view: sut.inject(appState, interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_failed() {
        var appState = AppState()
        appState.userData.countries = .failed(NSError.test)
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountriesList(didSetCountries: { view in
            view.inspectContent { content in
                XCTAssertNoThrow(try content.view(ErrorView.self))
            }
            interactors.asyncVerify(exp)
        })
        ViewHosting.host(view: sut.inject(appState, interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_failed_retry() {
        var appState = AppState()
        appState.userData.countries = .failed(NSError.test)
        let interactors = DIContainer.Interactors.mocked(
            countriesInteractor: [.loadCountries])
        let container = DIContainer(appState: .init(appState),
                                    interactors: interactors)
        let exp = XCTestExpectation(description: "onAppear")
        var isFirstUpdate = true
        let sut = CountriesList(didSetCountries: { view in
            guard isFirstUpdate
                else { return } // Skip the update after triggering the refresh
            isFirstUpdate = false
            view.inspectContent { content in
                let errorView = try content.view(ErrorView.self)
                try errorView.vStack().button(2).tap()
            }
            interactors.asyncVerify(exp)
        })
        ViewHosting.host(view: sut.inject(container))
        wait(for: [exp], timeout: 2)
    }
}

// MARK: - CountriesList inspection helpers

private extension CountriesList {
    
    func inspectContent(file: StaticString = #file, line: UInt = #line,
                        traverse: (InspectableView<ViewType.AnyView>) throws -> Void) {
        do {
            let content = try inspectContent()
            try traverse(content)
        } catch let error {
            XCTFail("\(error.localizedDescription)", file: file, line: line)
        }
    }
    
    private func inspectContent() throws -> InspectableView<ViewType.AnyView> {
        return try inspect().geometryReader().navigationView().anyView(0)
    }
}
