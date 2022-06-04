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
            XCTAssertNoThrow(try view.find(text: ""))
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
            XCTAssertNoThrow(try view.find(ActivityIndicatorView.self))
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
            XCTAssertNoThrow(try view.find(ActivityIndicatorView.self))
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
            XCTAssertNoThrow(try view.find(ActivityIndicatorView.self))
            try view.find(button: "Cancel loading").tap()
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
            XCTAssertNoThrow(try view.find(ImageView.self))
            XCTAssertNoThrow(try view.find(DetailRow.self).find(text: self.country.alpha3Code))
            interactors.verify()
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 3)
    }
    
    func test_details_failed() {
        let interactors = DIContainer.Interactors.mocked()
        let sut = CountryDetails(country: country, details: .failed(NSError.test))
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ErrorView.self))
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
            let errorView = try view.find(ErrorView.self)
            try errorView.vStack().button(2).tap()
            interactors.verify()
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_sheetPresentation() {
        let images: [MockedImagesInteractor.Action] = [.loadImage(country.flag), .loadImage(country.flag)]
        let interactors = DIContainer.Interactors.mocked(
            imagesInteractor: images
        )
        let container = DIContainer(appState: .init(AppState()), interactors: interactors)
        XCTAssertFalse(container.appState.value.routing.countryDetails.detailsSheet)
        let sut = CountryDetails(country: country, details: .loaded(Country.Details.mockedData[0]))
        let exp1 = sut.inspection.inspect { view in
            try view.find(ImageView.self).callOnTapGesture()
        }
        let exp2 = sut.inspection.inspect(after: 0.5) { view in
            XCTAssertTrue(container.appState.value.routing.countryDetails.detailsSheet)
            interactors.verify()
        }
        ViewHosting.host(view: sut.inject(container))
        wait(for: [exp1, exp2], timeout: 2)
    }
}
