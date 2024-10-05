//
//  SceneDelegateTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 26.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import XCTest
import UIKit
@testable import Orbit

final class SceneDelegateTests: XCTestCase {
    
    @MainActor
    private lazy var scene: UIScene = {
        UIApplication.shared.connectedScenes.first!
    }()
    
    @MainActor
    func test_openURLContexts() {
        let sut = SceneDelegate()
        let eventsHandler = MockedSystemEventsHandler(expected: [
            .openURL
        ])
        sut.systemEventsHandler = eventsHandler
        sut.scene(scene, openURLContexts: .init())
        eventsHandler.verify()
    }
    
    @MainActor
    func test_didBecomeActive() {
        let sut = SceneDelegate()
        let eventsHandler = MockedSystemEventsHandler(expected: [
            .becomeActive
        ])
        sut.systemEventsHandler = eventsHandler
        sut.sceneDidBecomeActive(scene)
        eventsHandler.verify()
    }
    
    @MainActor
    func test_willResignActive() {
        let sut = SceneDelegate()
        let eventsHandler = MockedSystemEventsHandler(expected: [
            .resignActive
        ])
        sut.systemEventsHandler = eventsHandler
        sut.sceneWillResignActive(scene)
        eventsHandler.verify()
    }
}
