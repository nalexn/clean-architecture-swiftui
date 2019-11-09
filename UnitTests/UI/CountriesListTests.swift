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
        let interactors = InteractorsContainer.mocked(
            countriesInteractor: [.loadCountries])
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountriesList().asyncOnAppear {
            interactors.verify()
            RootViewInjection.unmount()
            exp.fulfill()
        }
        RootViewInjection.mount(view: sut, injector: DependencyInjector(appState: appState, interactors: interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_isLoading_initial() {
        let appState = AppState()
        let interactors = InteractorsContainer.mocked()
        appState.userData.countries = .isLoading(last: nil)
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountriesList().asyncOnAppear {
            interactors.verify()
            RootViewInjection.unmount()
            exp.fulfill()
        }
        RootViewInjection.mount(view: sut, injector: DependencyInjector(appState: appState, interactors: interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_isLoading_refresh() {
        let appState = AppState()
        appState.userData.countries = .isLoading(last: Country.mockedData)
        let interactors = InteractorsContainer.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountriesList().asyncOnAppear {
            interactors.verify()
            RootViewInjection.unmount()
            exp.fulfill()
        }
        RootViewInjection.mount(view: sut, injector: DependencyInjector(appState: appState, interactors: interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_loaded() {
        let appState = AppState()
        appState.userData.countries = .loaded(Country.mockedData)
        let interactors = InteractorsContainer.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountriesList().asyncOnAppear {
            interactors.verify()
            RootViewInjection.unmount()
            exp.fulfill()
        }
        RootViewInjection.mount(view: sut, injector: DependencyInjector(appState: appState, interactors: interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_failed() {
        let appState = AppState()
        appState.userData.countries = .failed(NSError.test)
        let interactors = InteractorsContainer.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountriesList().asyncOnAppear {
            interactors.verify()
            RootViewInjection.unmount()
            exp.fulfill()
        }
        RootViewInjection.mount(view: sut, injector: DependencyInjector(appState: appState, interactors: interactors))
        wait(for: [exp], timeout: 2)
    }
}
