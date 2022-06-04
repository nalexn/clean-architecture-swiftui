//
//  ModalDetailsViewTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 01.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import CountriesSwiftUI

extension ModalDetailsView: Inspectable { }

final class ModalDetailsViewTests: XCTestCase {

    func test_modalDetails() {
        let country = Country.mockedData[0]
        let interactors = DIContainer.Interactors.mocked(
            imagesInteractor: [.loadImage(country.flag)]
        )
        let isDisplayed = Binding(wrappedValue: true)
        let sut = ModalDetailsView(country: country, isDisplayed: isDisplayed)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ImageView.self))
            XCTAssertNoThrow(try view.find(button: "Close"))
            interactors.verify()
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_modalDetails_close() {
        let country = Country.mockedData[0]
        let interactors = DIContainer.Interactors.mocked(
            imagesInteractor: [.loadImage(country.flag)]
        )
        let isDisplayed = Binding(wrappedValue: true)
        let sut = ModalDetailsView(country: country, isDisplayed: isDisplayed)
        let exp = sut.inspection.inspect { view in
            XCTAssertTrue(isDisplayed.wrappedValue)
            try view.find(button: "Close").tap()
            XCTAssertFalse(isDisplayed.wrappedValue)
            interactors.verify()
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_modalDetails_close_localization() throws {
        let isDisplayed = Binding(wrappedValue: true)
        let sut = ModalDetailsView(country: Country.mockedData[0], isDisplayed: isDisplayed)
        let labelText = try sut.inspect().find(text: "Close")
        XCTAssertEqual(try labelText.string(), "Close")
        XCTAssertEqual(try labelText.string(locale: Locale(identifier: "fr")), "Fermer")
    }
}
