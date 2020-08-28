//
//  DeepLinksHandlerTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 26.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import XCTest
@testable import CountriesSwiftUI

class DeepLinksHandlerTests: XCTestCase {

    func test_noSideEffectOnInit() {
        let services: DIContainer.Services = .mocked()
        let container = DIContainer(appState: AppState(), services: services)
        _ = RealDeepLinksHandler(container: container)
        services.verify()
        XCTAssertEqual(container.appState.value, AppState())
    }
    
    func test_openingDeeplinkFromDefaultRouting() {
        let services: DIContainer.Services = .mocked()
        let initialState = AppState()
        let container = DIContainer(appState: initialState, services: services)
        let sut = RealDeepLinksHandler(container: container)
        sut.open(deepLink: .showCountryFlag(alpha3Code: "ITA"))
        XCTAssertNil(initialState.routing.countriesList.countryDetails)
        XCTAssertFalse(initialState.routing.countryDetails.detailsSheet)
        var expectedState = AppState()
        expectedState.routing.countriesList.countryDetails = "ITA"
        expectedState.routing.countryDetails.detailsSheet = true
        services.verify()
        XCTAssertEqual(container.appState.value, expectedState)
    }
    
    func test_openingDeeplinkFromNonDefaultRouting() {
        let services: DIContainer.Services = .mocked()
        var initialState = AppState()
        initialState.routing.countriesList.countryDetails = "FRA"
        initialState.routing.countryDetails.detailsSheet = true
        let container = DIContainer(appState: initialState, services: services)
        let sut = RealDeepLinksHandler(container: container)
        sut.open(deepLink: .showCountryFlag(alpha3Code: "ITA"))
        
        let resettedState = AppState()
        var finalState = AppState()
        finalState.routing.countriesList.countryDetails = "ITA"
        finalState.routing.countryDetails.detailsSheet = true
        
        XCTAssertEqual(container.appState.value, resettedState)
        let exp = XCTestExpectation(description: #function)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            services.verify()
            XCTAssertEqual(container.appState.value, finalState)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.5)
    }
}
