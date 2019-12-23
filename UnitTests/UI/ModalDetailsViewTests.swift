//
//  ModalDetailsViewTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 01.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import SwiftUI
@testable import CountriesSwiftUI

class ModalDetailsViewTests: XCTestCase {

    func test_modalDetails() {
        let country = Country.mockedData[0]
        let interactors = DIContainer.Interactors.mocked(
            imagesInteractor: [.loadImage(country.flag)]
        )
        let exp = XCTestExpectation(description: "onAppear")
        let isDisplayed = State<Bool>(initialValue: true)
        let sut = ModalDetailsView(country: country, isDisplayed: isDisplayed.projectedValue)
            .asyncOnAppear {
                interactors.verify()
                ContentView.unmount()
                exp.fulfill()
            }
        ContentView.mount(view: sut, appState: AppState(), interactors: interactors)
        wait(for: [exp], timeout: 2)
    }
}
