//
//  ModalFlagViewTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 01.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Testing
import SwiftUI
import ViewInspector
@testable import CountriesSwiftUI

@MainActor
@Suite struct ModalFlagViewTests {

    private let country: DBModel.Country = ApiModel.Country.mockedData[0].dbModel()

    @Test func modalDetails() async throws {
        let container = DIContainer(interactors: .mocked(
            images: [.loadImage(country.flag)]
        ))
        let isDisplayed = Binding(wrappedValue: true)
        let sut = ModalFlagView(country: country, isDisplayed: isDisplayed)
        try await ViewHosting.host(sut.inject(container)) {
            try await sut.inspection.inspect { view in
                #expect(throws: Never.self) { try view.find(ImageView.self) }
                #expect(throws: Never.self) { try view.find(button: "Close") }
                container.interactors.verify()
            }
        }
    }

    @Test func modalDetailsClose() async throws {
        let container = DIContainer(interactors: .mocked(
            images: [.loadImage(country.flag)]
        ))
        let isDisplayed = Binding(wrappedValue: true)
        let sut = ModalFlagView(country: country, isDisplayed: isDisplayed)
        try await ViewHosting.host(sut.inject(container)) {
            try await sut.inspection.inspect { view in
                #expect(isDisplayed.wrappedValue)
                try view.find(button: "Close").tap()
                #expect(!isDisplayed.wrappedValue)
                container.interactors.verify()
            }
        }
    }

    @Test func modalDetailsCloseLocalization() throws {
        let isDisplayed = Binding(wrappedValue: true)
        let sut = ModalFlagView(country: country, isDisplayed: isDisplayed)
        let labelText = try sut.inspect().find(text: "Close")
        #expect(try labelText.string() == "Close")
        #expect(try labelText.string(locale: Locale(identifier: "de")) == "Schließen")
    }
}
