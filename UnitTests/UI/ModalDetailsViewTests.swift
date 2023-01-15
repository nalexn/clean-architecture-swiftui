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

final class ModalDetailsViewTests: XCTestCase {
    
    let country = Country.mockedData[0]
    
    func modalDetailsView(_ isDisplayed: Binding<Bool>, _ services: DIContainer.Services) -> ModalDetailsView {
        let container = DIContainer(appState: AppState(), services: services)
        let viewModel = ModalDetailsView.ViewModel(
            container: container, country: country, isDisplayed: isDisplayed)
        return ModalDetailsView(viewModel: viewModel)
    }

    func test_modalDetails() {
        let services = DIContainer.Services.mocked(
            imagesService: [.loadImage(country.flag)]
        )
        let isDisplayed = Binding(wrappedValue: true)
        let sut = modalDetailsView(isDisplayed, services)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ImageView.self))
            XCTAssertNoThrow(try view.find(button: "Close"))
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_modalDetails_close() {
        let services = DIContainer.Services.mocked(
            imagesService: [.loadImage(country.flag)]
        )
        let isDisplayed = Binding(wrappedValue: true)
        let sut = modalDetailsView(isDisplayed, services)
        let exp = sut.inspection.inspect { view in
            XCTAssertTrue(isDisplayed.wrappedValue)
            try view.find(button: "Close").tap()
            XCTAssertFalse(isDisplayed.wrappedValue)
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_modalDetails_close_localization() throws {
        let services = DIContainer.Services.mocked(
            imagesService: [.loadImage(country.flag)]
        )
        let isDisplayed = Binding(wrappedValue: true)
        let sut = modalDetailsView(isDisplayed, services)
        let labelText = try sut.inspect().find(text: "Close")
        XCTAssertEqual(try labelText.string(), "Close")
        XCTAssertEqual(try labelText.string(locale: Locale(identifier: "fr")), "Fermer")
    }
}
