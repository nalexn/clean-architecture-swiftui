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
@testable import CountriesSwiftUI

final class RootViewAppearanceTests: XCTestCase {

    func test_blur_whenInactive() {
        let sut = RootViewAppearance()
        let container = DIContainer(appState: .init(AppState()),
                                    interactors: .mocked())
        XCTAssertFalse(container.appState.value.system.isActive)
        let exp = sut.inspection.inspect { modifier in
            let content = try modifier.viewModifierContent()
            XCTAssertEqual(try content.blur().radius, 10)
        }
        let view = EmptyView().modifier(sut)
            .environment(\.injected, container)
        ViewHosting.host(view: view)
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_blur_whenActive() {
        let sut = RootViewAppearance()
        let container = DIContainer(appState: .init(AppState()),
                                    interactors: .mocked())
        container.appState[\.system.isActive] = true
        XCTAssertTrue(container.appState.value.system.isActive)
        let exp = sut.inspection.inspect { modifier in
            let content = try modifier.viewModifierContent()
            XCTAssertEqual(try content.blur().radius, 0)
        }
        let view = EmptyView().modifier(sut)
            .environment(\.injected, container)
        ViewHosting.host(view: view)
        wait(for: [exp], timeout: 0.1)
    }
}
