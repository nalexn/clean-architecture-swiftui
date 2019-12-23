//
//  CountriesListTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 01.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
@testable import CountriesSwiftUI

class CountriesListTests: XCTestCase {

    func test_countries_notRequested() {
        var appState = AppState()
        appState.userData.countries = .notRequested
        let interactors = DIContainer.Interactors.mocked(
            countriesInteractor: [.loadCountries])
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountriesList().asyncOnAppear {
            interactors.verify()
            ContentView.unmount()
            exp.fulfill()
        }
        ContentView.mount(view: sut, appState: appState, interactors: interactors)
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_isLoading_initial() {
        var appState = AppState()
        let interactors = DIContainer.Interactors.mocked()
        appState.userData.countries = .isLoading(last: nil)
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountriesList().asyncOnAppear {
            interactors.verify()
            ContentView.unmount()
            exp.fulfill()
        }
        ContentView.mount(view: sut, appState: appState, interactors: interactors)
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_isLoading_refresh() {
        var appState = AppState()
        appState.userData.countries = .isLoading(last: Country.mockedData)
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountriesList().asyncOnAppear {
            interactors.verify()
            ContentView.unmount()
            exp.fulfill()
        }
        ContentView.mount(view: sut, appState: appState, interactors: interactors)
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_loaded() {
        var appState = AppState()
        appState.userData.countries = .loaded(Country.mockedData)
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountriesList().asyncOnAppear {
            interactors.verify()
            ContentView.unmount()
            exp.fulfill()
        }
        ContentView.mount(view: sut, appState: appState, interactors: interactors)
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_failed() {
        var appState = AppState()
        appState.userData.countries = .failed(NSError.test)
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountriesList().asyncOnAppear {
            interactors.verify()
            ContentView.unmount()
            exp.fulfill()
        }
        ContentView.mount(view: sut, appState: appState, interactors: interactors)
        wait(for: [exp], timeout: 2)
    }
}
