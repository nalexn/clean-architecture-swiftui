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

extension CountryDetails: Inspectable { }
extension DetailRow: Inspectable { }

final class CountryDetailsTests: XCTestCase {
    
    let country = Country.mockedData[0]
    
    func countryDetailsView(_ details: Loadable<Country.Details>,
                            _ services: DIContainer.Services
    ) -> CountryDetails {
        CountryDetails(viewModel: CountryDetails.ViewModel(
            container: DIContainer(appState: AppState(), services: services),
            country: country, details: details))
    }

    func test_details_notRequested() {
        let services = DIContainer.Services.mocked(
            countriesService: [.loadCountryDetails(country)]
        )
        let sut = countryDetailsView(.notRequested, services)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.content().text())
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_isLoading_initial() {
        let services = DIContainer.Services.mocked()
        let sut = countryDetailsView(.isLoading(last: nil, cancelBag: CancelBag()), services)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.content().vStack().view(ActivityIndicatorView.self, 0))
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_isLoading_refresh() {
        let services = DIContainer.Services.mocked()
        let sut = countryDetailsView(.isLoading(last: Country.Details.mockedData[0], cancelBag: CancelBag()), services)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.content().vStack().view(ActivityIndicatorView.self, 0))
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
            let list = try view.content().list()
            XCTAssertNoThrow(try list.hStack(0).view(SVGImageView.self, 1))
            let countryCode = try list.section(1).view(DetailRow.self, 0)
                .hStack().text(0).string()
            XCTAssertEqual(countryCode, self.country.alpha3Code)
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 3)
    }
    
    func test_details_failed() {
        let services = DIContainer.Services.mocked()
        let sut = countryDetailsView(.failed(NSError.test), services)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.content().view(ErrorView.self))
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
            let errorView = try view.content().view(ErrorView.self)
            try errorView.vStack().button(2).tap()
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_sheetPresentation() {
        let services = DIContainer.Services.mocked(
            // Image is requested by CountryDetails and Details sheet:
            imagesService: [.loadImage(country.flag),
                               .loadImage(country.flag)]
        )
        let sut = countryDetailsView(.loaded(Country.Details.mockedData[0]), services)
        let container = sut.viewModel.container
        XCTAssertFalse(container.appState.value.routing.countryDetails.detailsSheet)
        let exp1 = sut.inspection.inspect { view in
            try view.content().list().hStack(0).view(SVGImageView.self, 1).callOnTapGesture()
        }
        let exp2 = sut.inspection.inspect(after: 0.5) { view in
            XCTAssertTrue(container.appState.value.routing.countryDetails.detailsSheet)
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp1, exp2], timeout: 2)
    }
}

// MARK: - CountryDetails inspection helper

extension InspectableView where View == ViewType.View<CountryDetails> {
    func content() throws -> InspectableView<ViewType.AnyView> {
        return try anyView()
    }
}
