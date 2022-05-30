//
//  DeepLinkUITests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 10.01.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import XCTest
import ViewInspector
import Combine
@testable import CountriesSwiftUI

final class DeepLinkUITests: XCTestCase {
    
    func test_countriesList_selectsCountry() {
        
        let store = appStateWithDeepLink()
        let interactors = mockedInteractors(store: store)
        let container = DIContainer(appState: store, interactors: interactors)
        let sut = CountriesList()
        let exp = sut.inspection.inspect(after: 0.1) { view in
            let firstRowLink = try view.content().find(ViewType.NavigationLink.self)
            XCTAssertTrue(try firstRowLink.isActive())
        }
        ViewHosting.host(view: sut.inject(container))
        wait(for: [exp], timeout: 2)
    }
    
    func test_countryDetails_presentsSheet() {
        
        let store = appStateWithDeepLink()
        let interactors = mockedInteractors(store: store)
        let container = DIContainer(appState: store, interactors: interactors)
        let sut = CountryDetails(country: Country.mockedData[0])
        let exp = sut.inspection.inspect(after: 0.1) { view in
            XCTAssertNoThrow(try view.find(ViewType.List.self))
            XCTAssertTrue(store.value.routing.countryDetails.detailsSheet)
        }
        ViewHosting.host(view: sut.inject(container))
        wait(for: [exp], timeout: 2)
    }
}

// MARK: - Setup

private extension DeepLinkUITests {
    
    func appStateWithDeepLink() -> Store<AppState> {
        let countries = Country.mockedData
        var appState = AppState()
        appState.routing.countriesList.countryDetails = countries[0].alpha3Code
        appState.routing.countryDetails.detailsSheet = true
        return Store(appState)
    }
    
    func mockedInteractors(store: Store<AppState>) -> DIContainer.Interactors {
        
        let countries = Country.mockedData
        let testImage = Data()
        let detailsIntermediate = Country.Details.Intermediate(capital: "", currencies: [], borders: [])
        let details = Country.Details(capital: "", currencies: [], neighbors: [])
        
        let countriesDBRepo = MockedCountriesDBRepository()
        let countriesWebRepo = MockedCountriesWebRepository()
        let imagesRepo = MockedImageWebRepository()
        
        // Mocking successful loading the list of countries:
        countriesDBRepo.hasLoadedCountriesResult = .success(false)
        countriesWebRepo.countriesResponse = .success(countries)
        countriesDBRepo.storeCountriesResult = .success(())
        countriesDBRepo.fetchCountriesResult = .success(countries.lazyList)
        
        // Mocking successful loading the country details:
        countriesDBRepo.fetchCountryDetailsResult = .success(nil)
        countriesWebRepo.detailsResponse = .success(detailsIntermediate)
        countriesDBRepo.storeCountryDetailsResult = .success(details)
        
        // Mocking successful loading of the flag:
        imagesRepo.imageResponse = .success(testImage)
        
        let countriesInteractor = RealCountriesInteractor(webRepository: countriesWebRepo,
                                                          dbRepository: countriesDBRepo,
                                                          appState: store)
        let imagesInteractor = RealImagesInteractor(webRepository: imagesRepo)
        let permissionsInteractor = RealUserPermissionsInteractor(appState: store, openAppSettings: { })
        return DIContainer.Interactors(countriesInteractor: countriesInteractor,
                                       imagesInteractor: imagesInteractor,
                                       userPermissionsInteractor: permissionsInteractor)
    }
}
