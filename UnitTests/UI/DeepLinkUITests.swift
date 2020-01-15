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
        
        let exp = XCTestExpectation(description: #function)
        exp.expectedFulfillmentCount = 2
        var sut = CountriesList()
        sut.didUpdate = { view in
            if store.value.userData.countries.value != nil {
                view.inspect { view in
                    let firstRowLink = try view.firstRowLink()
                    XCTAssertTrue(try firstRowLink.isActive())
                }
            }
            exp.fulfill()
        }
        ViewHosting.host(view: sut.inject(container))
        wait(for: [exp], timeout: 2)
    }
    
    func test_countryDetails_presentsSheet() {
        
        let store = appStateWithDeepLink()
        let interactors = mockedInteractors(store: store)
        let container = DIContainer(appState: store, interactors: interactors)
        
        let exp = XCTestExpectation(description: #function)
        var sut = CountryDetails(country: Country.mockedData[0])
        sut.didUpdate = { view in
            let loadedView = try? view.inspect().content().list()
            guard loadedView != nil else { return }
            XCTAssertTrue(store.value.routing.countryDetails.detailsSheet)
            // ViewInspector currently cannot extract .sheet
            // Since the `List` is present and `detailsSheet` is true
            // Assuming that the sheet is presented
            exp.fulfill()
        }
        ViewHosting.host(view: sut.inject(container))
        wait(for: [exp], timeout: 0.1)
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
        let countriesRepo = MockedCountriesWebRepository()
        countriesRepo.countriesResponse = .success(Country.mockedData)
        let details = Country.Details.Intermediate(capital: "", currencies: [], borders: [])
        countriesRepo.detailsResponse = .success(details)
        let imagesRepo = MockedImageWebRepository()
        let testImage = UIColor.red.image(CGSize(width: 40, height: 40))
        imagesRepo.imageResponse = .success(testImage)
        
        let countriesInteractor = RealCountriesInteractor(webRepository: countriesRepo, appState: store)
        let memoryWarning = PassthroughSubject<Void, Never>().eraseToAnyPublisher()
        let imagesInteractor = RealImagesInteractor(
            webRepository: imagesRepo, inMemoryCache: MockedImageCacheRepository(),
            fileCache: MockedImageCacheRepository(), memoryWarning: memoryWarning)
        return DIContainer.Interactors(countriesInteractor: countriesInteractor,
                                       imagesInteractor: imagesInteractor)
    }
}
