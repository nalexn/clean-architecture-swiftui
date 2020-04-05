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
        let exp = XCTestExpectation(description: #function)
        let container = DIContainer(appState: .init(AppState()),
                                    services: .mocked())
        XCTAssertFalse(container.appState.value.system.isActive)
        var sut = RootViewAppearance(viewModel: .init(container: container))
        sut.didAppear = { body in
            body.inspect { content in
                XCTAssertEqual(try content.blur().radius, 10)
            }
            ViewHosting.expel()
            exp.fulfill()
        }
        let view = EmptyView().modifier(sut)
        ViewHosting.host(view: view)
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_blur_whenActive() {
        let exp = XCTestExpectation(description: #function)
        let container = DIContainer(appState: .init(AppState()),
                                    services: .mocked())
        container.appState[\.system.isActive] = true
        XCTAssertTrue(container.appState.value.system.isActive)
        var sut = RootViewAppearance(viewModel: .init(container: container))
        sut.didAppear = { body in
            body.inspect { content in
                XCTAssertEqual(try content.blur().radius, 0)
            }
            ViewHosting.expel()
            exp.fulfill()
        }
        let view = EmptyView().modifier(sut)
        ViewHosting.host(view: view)
        wait(for: [exp], timeout: 0.1)
    }
}
