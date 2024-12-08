//
//  DeepLinkUITests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 10.01.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import Testing
import SwiftData
import ViewInspector
import UIKit.UIColor
@testable import CountriesSwiftUI

@MainActor
@Suite struct DeepLinkUITests {

    @Test func countriesListSelectsCountry() async throws {
        let store = appStateWithDeepLink()
        let interactors = interactorsWithMockedRepos(store: store)
        let modelContainer = ModelContainer.mock
        let dbRepository = MainDBRepository(modelContainer: modelContainer)
        let countries = ApiModel.Country.mockedData
        try await dbRepository.store(countries: countries)
        let container = DIContainer(appState: store, interactors: interactors)
        let sut = CountriesList()
        let view = sut.inject(container).modelContainer(modelContainer)
        try await ViewHosting.host(view) {
            try await sut.inspection.inspect { view in
                let actualView = try view.actualView()
                #expect(!actualView.navigationPath.isEmpty)
            }
        }
    }
    
    @Test func countryDetailsPresentsSheet() async throws {
        let store = appStateWithDeepLink()
        let interactors = interactorsWithMockedRepos(store: store)
        let container = DIContainer(appState: store, interactors: interactors)
        let country = ApiModel.Country.mockedData[0].dbModel()
        country.flag = URL(string: "https://sample.com")
        let countryDetails = DBModel.CountryDetails(alpha3Code: country.alpha3Code, capital: "Rome", currencies: [], neighbors: [])
        let sut = CountryDetails(country: country, details: .loaded(countryDetails))
        let view = sut.inject(container)
        try await ViewHosting.host(view) {
            try await sut.inspection.inspect(after: .seconds(0.5)) { view in
                #expect(throws: Never.self) { try view.find(ModalFlagView.self) }
                #expect(store.value.routing.countryDetails.detailsSheet)
            }
        }
    }
}

// MARK: - Setup

@MainActor
private extension DeepLinkUITests {
    
    func appStateWithDeepLink() -> Store<AppState> {
        let countries = ApiModel.Country.mockedData
        var appState = AppState()
        appState.routing.countriesList.countryCode = countries[0].alpha3Code
        appState.routing.countryDetails.detailsSheet = true
        return Store(appState)
    }
    
    func interactorsWithMockedRepos(store: Store<AppState>) -> DIContainer.Interactors {

        let countries = ApiModel.Country.mockedData
        let testImage = UIColor.red.image(CGSize(width: 40, height: 40))
        let detailsIntermediate = ApiModel.CountryDetails(capital: "", currencies: [], borders: [])
        let details = DBModel.CountryDetails(alpha3Code: "", capital: "", currencies: [], neighbors: [])

        let countriesDBRepo = MockedCountriesDBRepository()
        let countriesWebRepo = MockedCountriesWebRepository()
        let imagesRepo = MockedImageWebRepository()
        
        // Mocking successful loading the list of countries:
        countriesWebRepo.countriesResponses = [.success(countries)]
        countriesDBRepo.storeCountriesResults = [.success(())]

        // Mocking successful loading the country details:
        countriesDBRepo.countryDetailsResults = [.success(nil), .success(details)]
        countriesWebRepo.detailsResponses = [.success(detailsIntermediate)]
        countriesDBRepo.storeCountryDetailsResults = [.success(())]

        // Mocking successful loading of the flag:
        imagesRepo.imageResponses = [.success(testImage)]

        let countriesInteractor = RealCountriesInteractor(
            webRepository: countriesWebRepo,
            dbRepository: countriesDBRepo)
        let imagesInteractor = RealImagesInteractor(webRepository: imagesRepo)
        let permissionsInteractor = RealUserPermissionsInteractor(
            appState: store, openAppSettings: { })
        return DIContainer.Interactors(
            images: imagesInteractor,
            countries: countriesInteractor,
            userPermissions: permissionsInteractor)
    }
}

extension InspectableSheet: PopupPresenter { }
