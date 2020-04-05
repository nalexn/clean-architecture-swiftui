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

private typealias ModifierContent = _ViewModifier_Content<RootViewAppearance>

extension ModifierContent: Inspectable { }

final class RootViewAppearanceTests: XCTestCase {

    func test_blur_whenInactive() {
        let sut = RootViewAppearance()
        let exp = XCTestExpectation(description: #function)
        let container = DIContainer(appState: .init(AppState()),
                                    interactors: .mocked())
        XCTAssertFalse(container.appState.value.system.isActive)
        DispatchQueue.main.async {
            sut.inspection.send { body in
                body.inspect { content in
                    XCTAssertEqual(try content.anyView()
                        .view(ModifierContent.self).blur().radius, 10)
                }
                ViewHosting.expel()
                exp.fulfill()
            }
        }
        let view = EmptyView().modifier(sut)
            .environment(\.injected, container)
        ViewHosting.host(view: view)
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_blur_whenActive() {
        let sut = RootViewAppearance()
        let exp = XCTestExpectation(description: #function)
        let container = DIContainer(appState: .init(AppState()),
                                    interactors: .mocked())
        container.appState[\.system.isActive] = true
        XCTAssertTrue(container.appState.value.system.isActive)
        DispatchQueue.main.async {
            sut.inspection.send { body in
                body.inspect { content in
                    XCTAssertEqual(try content.anyView()
                        .view(ModifierContent.self).blur().radius, 0)
                }
                ViewHosting.expel()
                exp.fulfill()
            }
        }
        let view = EmptyView().modifier(sut)
            .environment(\.injected, container)
        ViewHosting.host(view: view)
        wait(for: [exp], timeout: 0.1)
    }
}
