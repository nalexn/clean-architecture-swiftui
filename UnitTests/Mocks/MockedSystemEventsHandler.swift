//
//  MockedSystemEventsHandler.swift
//  UnitTests
//
//  Created by Alexey Naumov on 26.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import XCTest
import Combine
@testable import CountriesSwiftUI

// MARK: - SystemEventsHandler

final class MockedSystemEventsHandler: Mock, SystemEventsHandler {
    enum Action: Equatable {
        case openURL
        case becomeActive
        case resignActive
        case pushRegistration
        case recevieRemoteNotification
    }
    var actions = MockActions<Action>(expected: [])
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func sceneOpenURLContexts(_ urlContexts: Set<UIOpenURLContext>) {
        register(.openURL)
    }
    
    func sceneDidBecomeActive() {
        register(.becomeActive)
    }
    
    func sceneWillResignActive() {
        register(.resignActive)
    }
    
    func handlePushRegistration(result: Result<Data, Error>) {
        register(.pushRegistration)
    }
    
    func appDidReceiveRemoteNotification(payload: NotificationPayload,
                                         fetchCompletion: @escaping FetchCompletion) {
        register(.recevieRemoteNotification)
    }
}

// MARK: - PushNotificationsHandler

final class DummyPushNotificationsHandler: PushNotificationsHandler { }

// MARK: - DeepLinksHandler

final class MockedDeepLinksHandler: Mock, DeepLinksHandler {
    enum Action: Equatable {
        case open(DeepLink)
    }
    var actions = MockActions<Action>(expected: [])
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func open(deepLink: DeepLink) {
        register(.open(deepLink))
    }
}
