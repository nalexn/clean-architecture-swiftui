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
        let interactors = InteractorsContainer.mocked(
            countriesInteractor: [.loadCountryDetails(country)])
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountryDetails(country: country, details: .notRequested)
            .asyncOnAppear {
                interactors.verify()
                RootViewInjection.unmount()
                exp.fulfill()
            }
        RootViewInjection.mount(view: sut, environment: RootViewModifier(appState: AppState(), interactors: interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_isLoading_initial() {
        let interactors = InteractorsContainer.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountryDetails(country: country, details: .isLoading(last: nil))
            .asyncOnAppear {
                interactors.verify()
                RootViewInjection.unmount()
                exp.fulfill()
            }
        RootViewInjection.mount(view: sut, environment: RootViewModifier(appState: AppState(), interactors: interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_isLoading_refresh() {
        let interactors = InteractorsContainer.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountryDetails(country: country, details: .isLoading(last: Country.Details.mockedData[0]))
            .asyncOnAppear {
                interactors.verify()
                RootViewInjection.unmount()
                exp.fulfill()
            }
        RootViewInjection.mount(view: sut, environment: RootViewModifier(appState: AppState(), interactors: interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_loaded() {
        let interactors = InteractorsContainer.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountryDetails(country: country, details: .loaded(Country.Details.mockedData[0]))
            .asyncOnAppear {
                interactors.verify()
                RootViewInjection.unmount()
                exp.fulfill()
            }
        RootViewInjection.mount(view: sut, environment: RootViewModifier(appState: AppState(), interactors: interactors))
        wait(for: [exp], timeout: 3)
    }
    
    func test_details_failed() {
        let interactors = InteractorsContainer.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountryDetails(country: country, details: .failed(NSError.test))
            .asyncOnAppear {
                interactors.verify()
                RootViewInjection.unmount()
                exp.fulfill()
            }
        RootViewInjection.mount(view: sut, environment: RootViewModifier(appState: AppState(), interactors: interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_sheetPresentation() {
        let appState = AppState()
        appState.routing.countryDetails.detailsSheet = true
        let interactors = InteractorsContainer.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountryDetails(country: country, details: .loaded(Country.Details.mockedData[0]))
            .asyncOnAppear {
                interactors.verify()
                RootViewInjection.unmount()
                exp.fulfill()
            }
        RootViewInjection.mount(view: sut, environment: RootViewModifier(appState: appState, interactors: interactors))
        wait(for: [exp], timeout: 2)
    }
}
