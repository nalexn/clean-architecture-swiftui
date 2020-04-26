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

    func test_details_notRequested() {
        let interactors = DIContainer.Interactors.mocked(
            countriesInteractor: [.loadCountryDetails(country)]
        )
        let sut = CountryDetails(country: country, details: .notRequested)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.content().text())
            interactors.verify()
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_isLoading_initial() {
        let interactors = DIContainer.Interactors.mocked()
        let sut = CountryDetails(country: country, details:
            .isLoading(last: nil, cancelBag: CancelBag()))
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.content().vStack().view(ActivityIndicatorView.self, 0))
            interactors.verify()
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_isLoading_refresh() {
        let interactors = DIContainer.Interactors.mocked()
        let sut = CountryDetails(country: country, details:
            .isLoading(last: Country.Details.mockedData[0], cancelBag: CancelBag())
        )
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.content().vStack().view(ActivityIndicatorView.self, 0))
            interactors.verify()
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_isLoading_cancellation() {
        let interactors = DIContainer.Interactors.mocked()
        let sut = CountryDetails(country: country, details:
            .isLoading(last: Country.Details.mockedData[0], cancelBag: CancelBag())
        )
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.content().vStack().view(ActivityIndicatorView.self, 0))
            try view.content().vStack().button(1).tap()
            interactors.verify()
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_loaded() {
        let interactors = DIContainer.Interactors.mocked(
            imagesInteractor: [.loadImage(country.flag)]
        )
        let sut = CountryDetails(country: country, details:
            .loaded(Country.Details.mockedData[0])
        )
        let exp = sut.inspection.inspect { view in
            let list = try view.content().list()
            XCTAssertNoThrow(try list.hStack(0).view(SVGImageView.self, 1))
            let countryCode = try list.section(1).view(DetailRow.self, 0)
                .hStack().text(0).string()
            XCTAssertEqual(countryCode, self.country.alpha3Code)
            interactors.verify()
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 3)
    }
    
    func test_details_failed() {
        let interactors = DIContainer.Interactors.mocked()
        let sut = CountryDetails(country: country, details: .failed(NSError.test))
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.content().view(ErrorView.self))
            interactors.verify()
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_details_failed_retry() {
        let interactors = DIContainer.Interactors.mocked(
            countriesInteractor: [.loadCountryDetails(country)]
        )
        let sut = CountryDetails(country: country, details: .failed(NSError.test))
        let exp = sut.inspection.inspect { view in
            let errorView = try view.content().view(ErrorView.self)
            try errorView.vStack().button(2).tap()
            interactors.verify()
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_sheetPresentation() {
        let interactors = DIContainer.Interactors.mocked(
            // Image is requested by CountryDetails and Details sheet:
            imagesInteractor: [.loadImage(country.flag),
                               .loadImage(country.flag)]
        )
        let container = DIContainer(appState: .init(AppState()), interactors: interactors)
        XCTAssertFalse(container.appState.value.routing.countryDetails.detailsSheet)
        let sut = CountryDetails(country: country, details: .loaded(Country.Details.mockedData[0]))
        let exp1 = sut.inspection.inspect { view in
            try view.content().list().hStack(0).view(SVGImageView.self, 1).callOnTapGesture()
        }
        let exp2 = sut.inspection.inspect(after: 0.5) { view in
            XCTAssertTrue(container.appState.value.routing.countryDetails.detailsSheet)
            interactors.verify()
        }
        ViewHosting.host(view: sut.inject(container))
        wait(for: [exp1, exp2], timeout: 2)
    }
}

// MARK: - CountryDetails inspection helper

extension InspectableView where View == ViewType.View<CountryDetails> {
    func content() throws -> InspectableView<ViewType.AnyView> {
        return try anyView()
    }
}
