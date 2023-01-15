//
//  CountryDetailsTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 01.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import ViewInspector
@testable import CountriesSwiftUI

final class CountryDetailsTests: XCTestCase {
    
    let country = Country.mockedData[0]
    
    func countryDetailsView(_ details: Loadable<Country.Details>,
                            _ services: DIContainer.Services
    ) -> CountryDetails {
        let container = DIContainer(appState: AppState(), services: services)
        let viewModel = CountryDetails.ViewModel(
            container: container, country: country, details: details)
        return CountryDetails(viewModel: viewModel)
    }

    func test_details_notRequested() {
        let services = DIContainer.Services.mocked(
            countriesService: [.loadCountryDetails(country)]
        )
        let sut = countryDetailsView(.notRequested, services)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(text: ""))
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_isLoading_initial() {
        let services = DIContainer.Services.mocked()
        let sut = countryDetailsView(.isLoading(last: nil, cancelBag: CancelBag()), services)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ActivityIndicatorView.self))
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_isLoading_refresh() {
        let services = DIContainer.Services.mocked()
        let sut = countryDetailsView(.isLoading(last: Country.Details.mockedData[0], cancelBag: CancelBag()), services)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ActivityIndicatorView.self))
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_isLoading_cancellation() {
        let services = DIContainer.Services.mocked()
        let container = DIContainer(appState: AppState(), services: services)
        let viewModel = CountryDetails.ViewModel(
            container: container, country: country, details:
            .isLoading(last: Country.Details.mockedData[0], cancelBag: CancelBag()))
        let sut = CountryDetails(viewModel: viewModel)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ActivityIndicatorView.self))
            try view.find(button: "Cancel loading").tap()
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_loaded() {
        let services = DIContainer.Services.mocked(
            imagesService: [.loadImage(country.flag)]
        )
        let sut = countryDetailsView(.loaded(Country.Details.mockedData[0]), services)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ImageView.self))
            XCTAssertNoThrow(try view.find(DetailRow.self).find(text: self.country.alpha3Code))
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 3)
    }
    
    func test_details_failed() {
        let services = DIContainer.Services.mocked()
        let sut = countryDetailsView(.failed(NSError.test), services)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ErrorView.self))
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_failed_retry() {
        let services = DIContainer.Services.mocked(
            countriesService: [.loadCountryDetails(country)]
        )
        let sut = countryDetailsView(.failed(NSError.test), services)
        let exp = sut.inspection.inspect { view in
            let errorView = try view.find(ErrorView.self)
            try errorView.vStack().button(2).tap()
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_sheetPresentation() {
        let images: [MockedImagesService.Action] = [.loadImage(country.flag), .loadImage(country.flag)]
        let services = DIContainer.Services.mocked(
            imagesService: images
        )
        let sut = countryDetailsView(.loaded(Country.Details.mockedData[0]), services)
        let container = sut.viewModel.container
        XCTAssertFalse(container.appState.value.routing.countryDetails.detailsSheet)
        let exp1 = sut.inspection.inspect { view in
            try view.find(ImageView.self).callOnTapGesture()
        }
        let exp2 = sut.inspection.inspect(after: 0.5) { view in
            XCTAssertTrue(container.appState.value.routing.countryDetails.detailsSheet)
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp1, exp2], timeout: 2)
    }
}
