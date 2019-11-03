//
//  CountryDetailsTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 01.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
@testable import CountriesSwiftUI

class CountryDetailsTests: XCTestCase {
    
    let country = Country.mockedData[0]

    func test_details_notRequested() {
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountryDetails(country: country, details: .notRequested)
            .asyncOnAppear {
                RootViewInjection.unmount()
                exp.fulfill()
            }
        RootViewInjection.mount(view: sut, environment: RootViewModifier(appState: AppState()))
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_isLoading_initial() {
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountryDetails(country: country, details: .isLoading(last: nil))
            .asyncOnAppear {
                RootViewInjection.unmount()
                exp.fulfill()
            }
        RootViewInjection.mount(view: sut, environment: RootViewModifier(appState: AppState()))
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_isLoading_refresh() {
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountryDetails(country: country, details: .isLoading(last: Country.Details.mockedData[0]))
            .asyncOnAppear {
                RootViewInjection.unmount()
                exp.fulfill()
            }
        RootViewInjection.mount(view: sut, environment: RootViewModifier(appState: AppState()))
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_loaded() {
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountryDetails(country: country, details: .loaded(Country.Details.mockedData[0]))
            .asyncOnAppear {
                RootViewInjection.unmount()
                exp.fulfill()
            }
        RootViewInjection.mount(view: sut, environment: RootViewModifier(appState: AppState()))
        wait(for: [exp], timeout: 3)
    }
    
    func test_details_failed() {
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountryDetails(country: country, details: .failed(NSError.test))
            .asyncOnAppear {
                RootViewInjection.unmount()
                exp.fulfill()
            }
        RootViewInjection.mount(view: sut, environment: RootViewModifier(appState: AppState()))
        wait(for: [exp], timeout: 2)
    }
    
    func test_sheetPresentation() {
        let appState = AppState()
        appState.routing.countryDetails.detailsSheet = true
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountryDetails(country: country, details: .loaded(Country.Details.mockedData[0]))
            .asyncOnAppear {
                RootViewInjection.unmount()
                exp.fulfill()
            }
        RootViewInjection.mount(view: sut, environment: RootViewModifier(appState: appState))
        wait(for: [exp], timeout: 2)
    }
}
