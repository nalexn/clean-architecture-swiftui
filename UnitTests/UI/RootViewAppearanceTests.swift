//
//  RootViewAppearanceTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 05.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import Testing
import SwiftUI
import ViewInspector
@testable import CountriesSwiftUI

@MainActor
@Suite struct RootViewAppearanceTests {

    @Test func blurWhenInactive() async throws {
        let sut = RootViewAppearance()
        let container = DIContainer(interactors: .mocked())
        #expect(!container.appState.value.system.isActive)
        let view = EmptyView().modifier(sut)
            .inject(container)
        try await ViewHosting.host(view) {
            try await sut.inspection.inspect { modifier in
                let content = try modifier.implicitAnyView().viewModifierContent()
                #expect(try content.blur().radius == 10)
            }
        }
    }
    
    @Test func blurWhenActive() async throws {
        let sut = RootViewAppearance()
        let container = DIContainer(interactors: .mocked())
        container.appState[\.system.isActive] = true
        #expect(container.appState.value.system.isActive)
        let view = EmptyView().modifier(sut)
            .inject(container)
        try await ViewHosting.host(view) {
            try await sut.inspection.inspect { modifier in
                let content = try modifier.implicitAnyView().viewModifierContent()
                #expect(try content.blur().radius == 0)
            }
        }
    }
}
