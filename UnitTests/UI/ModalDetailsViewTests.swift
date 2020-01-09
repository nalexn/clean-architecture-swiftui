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
        var sut = WrapperView(country: country, isDisplayed: true)
        sut.didAppear = { view in
            view.inspectContent { content in
                let vStack = try content.view(ModalDetailsView.self).navigationView().vStack(0)
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
        var sut = WrapperView(country: country, isDisplayed: true)
        sut.didAppear = { view in
            view.inspectContent { content in
                try content.view(ModalDetailsView.self).navigationView().vStack(0).button(1).tap()
                let isDisplayed = try content.actualView().isDisplayed
                XCTAssertFalse(isDisplayed)
            }
            interactors.asyncVerify(exp)
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
}

// MARK: - WrapperView

private struct WrapperView: View, Inspectable {
    
    let country: Country
    @State var isDisplayed: Bool
    var didAppear: ((Self) -> Void)?
    
    var body: some View {
        ModalDetailsView(country: country, isDisplayed: $isDisplayed)
            .onAppear { self.didAppear?(self) }
    }
    
    func inspectContent(file: StaticString = #file, line: UInt = #line,
                        traverse: (InspectableView<ViewType.View<WrapperView>>) throws -> Void) {
        do {
            try traverse(try inspect())
        } catch let error {
            XCTFail("\(error.localizedDescription)", file: file, line: line)
        }
    }
}
