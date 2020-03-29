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
        let services = DIContainer.Services.mocked(
            imagesService: [.loadImage(country.flag)]
        )
        let isDisplayed = Binding(wrappedValue: true)
        let sut = ModalDetailsView(country: country, isDisplayed: isDisplayed)
        let exp = sut.inspection.inspect { view in
            let vStack = try view.navigationView().vStack(0)
            XCTAssertNoThrow(try vStack.hStack(0).view(SVGImageView.self, 1))
            XCTAssertNoThrow(try vStack.button(1))
            services.verify()
        }
        ViewHosting.host(view: sut.inject(AppState(), services))
        wait(for: [exp], timeout: 2)
    }
    
    func test_modalDetails_close() {
        let country = Country.mockedData[0]
        let services = DIContainer.Services.mocked(
            imagesService: [.loadImage(country.flag)]
        )
        let isDisplayed = Binding(wrappedValue: true)
        let sut = ModalDetailsView(country: country, isDisplayed: isDisplayed)
        let exp = sut.inspection.inspect { view in
            XCTAssertTrue(isDisplayed.wrappedValue)
            try view.navigationView().vStack(0).button(1).tap()
            XCTAssertFalse(isDisplayed.wrappedValue)
            services.verify()
        }
        ViewHosting.host(view: sut.inject(AppState(), services))
        wait(for: [exp], timeout: 2)
    }
}
