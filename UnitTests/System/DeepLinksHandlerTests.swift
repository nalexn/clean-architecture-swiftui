//
//  DeepLinksHandlerTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 26.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import Testing
@testable import CountriesSwiftUI

@MainActor
@Suite struct DeepLinksHandlerTests {

    @Test func noSideEffectOnInit() {
        let interactors: DIContainer.Interactors = .mocked()
        let container = DIContainer(appState: AppState(), interactors: interactors)
        _ = RealDeepLinksHandler(container: container)
        interactors.verify()
        #expect(container.appState.value == AppState())
    }

    @Test func openingDeeplinkFromDefaultRouting() {
        let interactors: DIContainer.Interactors = .mocked()
        let initialState = AppState()
        let container = DIContainer(appState: initialState, interactors: interactors)
        let sut = RealDeepLinksHandler(container: container)
        sut.open(deepLink: .showCountryFlag(alpha3Code: "ITA"))
        #expect(initialState.routing.countriesList.countryCode == nil)
        #expect(!initialState.routing.countryDetails.detailsSheet)
        var expectedState = AppState()
        expectedState.routing.countriesList.countryCode = "ITA"
        expectedState.routing.countryDetails.detailsSheet = true
        interactors.verify()
        #expect(container.appState.value == expectedState)
    }

    @Test func openingDeeplinkFromNonDefaultRouting() async throws {
        let interactors: DIContainer.Interactors = .mocked()
        var initialState = AppState()
        initialState.routing.countriesList.countryCode = "FRA"
        initialState.routing.countryDetails.detailsSheet = true
        let container = DIContainer(appState: initialState, interactors: interactors)
        let sut = RealDeepLinksHandler(container: container)
        sut.open(deepLink: .showCountryFlag(alpha3Code: "ITA"))

        let resettedState = AppState()
        var finalState = AppState()
        finalState.routing.countriesList.countryCode = "ITA"
        finalState.routing.countryDetails.detailsSheet = true

        #expect(container.appState.value == resettedState)
        try await Task.sleep(nanoseconds: 10_000_000)
        interactors.verify()
        #expect(container.appState.value == finalState)
    }
}

