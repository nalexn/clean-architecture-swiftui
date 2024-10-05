//
//  RootViewAppearanceTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 05.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import Orbit

@MainActor
final class RootViewAppearanceTests: XCTestCase {

    @MainActor
    func test_blur_whenInactive() {
        let container = DIContainer(appState: .init(AppState()),
                                    services: .mocked())
        let sut = RootViewAppearance(viewModel: .init(container: container))
        XCTAssertFalse(container.appState.value.system.isActive)
        let exp = sut.inspection.inspect { modifier in
            let content = try modifier.implicitAnyView().viewModifierContent()
            XCTAssertEqual(try content.blur().radius, 10)
        }
        let view = EmptyView().modifier(sut)
        ViewHosting.host(view: view)
        wait(for: [exp], timeout: 0.1)
    }
    
    @MainActor
    func test_blur_whenActive() {
        let container = DIContainer(appState: .init(AppState()),
                                    services: .mocked())
        container.appState[\.system.isActive] = true
        XCTAssertTrue(container.appState.value.system.isActive)
        let sut = RootViewAppearance(viewModel: .init(container: container))
        let exp = sut.inspection.inspect { modifier in
            let content = try modifier.implicitAnyView().viewModifierContent()
            XCTAssertEqual(try content.blur().radius, 0)
        }
        let view = EmptyView().modifier(sut)
        ViewHosting.host(view: view)
        wait(for: [exp], timeout: 0.1)
    }
}
