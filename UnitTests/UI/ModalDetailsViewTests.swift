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
        let interactors = InteractorsContainer.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let isDisplayed = State<Bool>(initialValue: true)
        let sut = ModalDetailsView(country: Country.mockedData[0], isDisplayed: isDisplayed.projectedValue)
            .asyncOnAppear {
                interactors.verify()
                RootViewInjection.unmount()
                exp.fulfill()
            }
        RootViewInjection.mount(view: sut, environment: RootViewModifier(appState: AppState(), interactors: interactors))
        wait(for: [exp], timeout: 2)
    }
}
