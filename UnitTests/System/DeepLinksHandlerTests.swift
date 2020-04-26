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
        let interactors: DIContainer.Interactors = .mocked()
        let container = DIContainer(appState: AppState(), interactors: interactors)
        _ = RealDeepLinksHandler(container: container)
        interactors.verify()
        XCTAssertEqual(container.appState.value, AppState())
    }
    
    func test_openingFlag() {
        let interactors: DIContainer.Interactors = .mocked()
        let initialState = AppState()
        let container = DIContainer(appState: initialState, interactors: interactors)
        let sut = RealDeepLinksHandler(container: container)
        sut.open(deepLink: .showCountryFlag(alpha3Code: "ITA"))
        XCTAssertNil(initialState.routing.countriesList.countryDetails)
        XCTAssertFalse(initialState.routing.countryDetails.detailsSheet)
        var expectedState = AppState()
        expectedState.routing.countriesList.countryDetails = "ITA"
        expectedState.routing.countryDetails.detailsSheet = true
        interactors.verify()
        XCTAssertEqual(container.appState.value, expectedState)
    }
}
