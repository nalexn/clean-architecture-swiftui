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
        let appState = AppState()
        appState.userData.countries = .notRequested
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountriesList().asyncOnAppear {
            RootViewInjection.unmount()
            exp.fulfill()
        }
        RootViewInjection.mount(view: sut, environment: RootViewModifier(appState: appState))
        wait(for: [exp], timeout: 1)
    }
    
    func test_countries_isLoading_initial() {
        let appState = AppState()
        appState.userData.countries = .isLoading(last: nil)
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountriesList().asyncOnAppear {
            RootViewInjection.unmount()
            exp.fulfill()
        }
        RootViewInjection.mount(view: sut, environment: RootViewModifier(appState: appState))
        wait(for: [exp], timeout: 1)
    }
    
    func test_countries_isLoading_refresh() {
        let appState = AppState()
        appState.userData.countries = .isLoading(last: Country.mockedData)
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountriesList().asyncOnAppear {
            RootViewInjection.unmount()
            exp.fulfill()
        }
        RootViewInjection.mount(view: sut, environment: RootViewModifier(appState: appState))
        wait(for: [exp], timeout: 1)
    }
    
    func test_countries_loaded() {
        let appState = AppState()
        appState.userData.countries = .loaded(Country.mockedData)
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountriesList().asyncOnAppear {
            RootViewInjection.unmount()
            exp.fulfill()
        }
        RootViewInjection.mount(view: sut, environment: RootViewModifier(appState: appState))
        wait(for: [exp], timeout: 1)
    }
    
    func test_countries_failed() {
        let appState = AppState()
        appState.userData.countries = .failed(NSError.test)
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountriesList().asyncOnAppear {
            RootViewInjection.unmount()
            exp.fulfill()
        }
        RootViewInjection.mount(view: sut, environment: RootViewModifier(appState: appState))
        wait(for: [exp], timeout: 1)
    }
}
