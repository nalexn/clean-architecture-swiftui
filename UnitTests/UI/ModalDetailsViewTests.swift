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

class ModalDetailsViewTests: XCTestCase {

    func test_modalDetails() {
        let country = Country.mockedData[0]
        let interactors = DIContainer.Interactors.mocked(
            imagesInteractor: [.loadImage(country.flag)]
        )
        let exp = XCTestExpectation(description: "onAppear")
        let isDisplayed = Binding(wrappedValue: true)
        var sut = ModalDetailsView(country: country, isDisplayed: isDisplayed)
        sut.didAppear = { view in
            view.inspect { content in
                let vStack = try content.navigationView().vStack(0)
                XCTAssertNoThrow(try vStack.hStack(0).view(SVGImageView.self, 1))
                XCTAssertNoThrow(try vStack.button(1))
            }
            interactors.asyncVerify(exp)
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_modalDetails_close() {
        let country = Country.mockedData[0]
        let interactors = DIContainer.Interactors.mocked(
            imagesInteractor: [.loadImage(country.flag)]
        )
        let exp = XCTestExpectation(description: "onAppear")
        let isDisplayed = Binding(wrappedValue: true)
        var sut = ModalDetailsView(country: country, isDisplayed: isDisplayed)
        sut.didAppear = { view in
            view.inspect { content in
                XCTAssertTrue(isDisplayed.wrappedValue)
                try content.navigationView().vStack(0).button(1).tap()
                XCTAssertFalse(isDisplayed.wrappedValue)
            }
            interactors.asyncVerify(exp)
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
}
