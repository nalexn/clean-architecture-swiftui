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
    
    func test_openingFlag() {
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
}
