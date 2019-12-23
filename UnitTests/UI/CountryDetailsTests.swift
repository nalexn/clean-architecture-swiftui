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
        let interactors = DIContainer.Interactors.mocked(
            countriesInteractor: [.loadCountryDetails(country)])
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountryDetails(country: country, details: .notRequested)
            .asyncOnAppear {
                interactors.verify()
                ContentView.unmount()
                exp.fulfill()
            }
        ContentView.mount(view: sut, appState: AppState(), interactors: interactors)
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_isLoading_initial() {
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountryDetails(country: country, details: .isLoading(last: nil))
            .asyncOnAppear {
                interactors.verify()
                ContentView.unmount()
                exp.fulfill()
            }
        ContentView.mount(view: sut, appState: AppState(), interactors: interactors)
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_isLoading_refresh() {
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountryDetails(country: country, details: .isLoading(last: Country.Details.mockedData[0]))
            .asyncOnAppear {
                interactors.verify()
                ContentView.unmount()
                exp.fulfill()
            }
        ContentView.mount(view: sut, appState: AppState(), interactors: interactors)
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_loaded() {
        let interactors = DIContainer.Interactors.mocked(
            imagesInteractor: [.loadImage(country.flag)])
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountryDetails(country: country, details: .loaded(Country.Details.mockedData[0]))
            .asyncOnAppear {
                interactors.verify()
                ContentView.unmount()
                exp.fulfill()
            }
        ContentView.mount(view: sut, appState: AppState(), interactors: interactors)
        wait(for: [exp], timeout: 3)
    }
    
    func test_details_failed() {
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountryDetails(country: country, details: .failed(NSError.test))
            .asyncOnAppear {
                interactors.verify()
                ContentView.unmount()
                exp.fulfill()
            }
        ContentView.mount(view: sut, appState: AppState(), interactors: interactors)
        wait(for: [exp], timeout: 2)
    }
    
    func test_sheetPresentation() {
        var appState = AppState()
        appState.routing.countryDetails.detailsSheet = true
        let interactors = DIContainer.Interactors.mocked(
            // Image is requested by CountryDetails and Details sheet:
            imagesInteractor: [.loadImage(country.flag),
                               .loadImage(country.flag)])
        let exp = XCTestExpectation(description: "onAppear")
        let sut = CountryDetails(country: country, details: .loaded(Country.Details.mockedData[0]))
            .asyncOnAppear {
                interactors.verify()
                ContentView.unmount()
                exp.fulfill()
            }
        ContentView.mount(view: sut, appState: appState, interactors: interactors)
        wait(for: [exp], timeout: 2)
    }
}
