//
//  PushNotificationsHandlerTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 26.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import Testing
import UserNotifications
@testable import CountriesSwiftUI

@MainActor
@Suite struct PushNotificationsHandlerTests {

    @Test func isCenterDelegate() {
        let mockedHandler = MockedDeepLinksHandler(expected: [])
        let sut = RealPushNotificationsHandler(deepLinksHandler: mockedHandler)
        let center = UNUserNotificationCenter.current()
        #expect(center.delegate === sut)
        mockedHandler.verify()
    }

    @Test func emptyPayload() async throws {
        let mockedHandler = MockedDeepLinksHandler(expected: [])
        let sut = RealPushNotificationsHandler(deepLinksHandler: mockedHandler)
        let exp = TestExpectation()
        sut.handleNotification(userInfo: [:]) {
            mockedHandler.verify()
            exp.fulfill()
        }
        await exp.fulfillment()
    }
    
    @Test func deepLinkPayload() async throws {
        let mockedHandler = MockedDeepLinksHandler(expected: [
            .open(.showCountryFlag(alpha3Code: "USA"))
        ])
        let sut = RealPushNotificationsHandler(deepLinksHandler: mockedHandler)
        let exp = TestExpectation()
        let userInfo: [String: Any] = [
            "aps": ["country": "USA"]
        ]
        sut.handleNotification(userInfo: userInfo) {
            mockedHandler.verify()
            exp.fulfill()
        }
        await exp.fulfillment()
    }
}
