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
        let services = mockedServices(store: store)
        let container = DIContainer(appState: store, services: services)
        let sut = CountriesList(viewModel: .init(container: container))
        let exp = sut.inspection.inspect(after: 0.1) { view in
            let firstRowLink = try view.content().find(ViewType.NavigationLink.self)
            XCTAssertTrue(try firstRowLink.isActive())
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_countryDetails_presentsSheet() {
        
        let store = appStateWithDeepLink()
        let services = mockedServices(store: store)
        let container = DIContainer(appState: store, services: services)
        let sut = CountryDetails(viewModel: .init(container: container, country: Country.mockedData[0]))
        let exp = sut.inspection.inspect(after: 0.1) { view in
            XCTAssertNoThrow(try view.find(ViewType.List.self))
            XCTAssertTrue(store.value.routing.countryDetails.detailsSheet)
        }
        ViewHosting.host(view: sut)
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
    
    func mockedServices(store: Store<AppState>) -> DIContainer.Services {
        
        let countries = Country.mockedData
        let testImage = UIColor.red.image(CGSize(width: 40, height: 40))
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
        
        let countriesService = RealCountriesService(webRepository: countriesWebRepo,
                                                    dbRepository: countriesDBRepo,
                                                    appState: store)
        let imagesService = RealImagesService(webRepository: imagesRepo)
        let permissionService = RealUserPermissionsService(appState: store, openAppSettings: { })
        return DIContainer.Services(countriesService: countriesService,
                                    imagesService: imagesService,
                                    userPermissionsService: permissionService)
    }
}
