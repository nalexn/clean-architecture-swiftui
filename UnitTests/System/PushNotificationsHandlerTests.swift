//
//  PushNotificationsHandlerTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 26.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import XCTest
import UserNotifications
@testable import CountriesSwiftUI

class PushNotificationsHandlerTests: XCTestCase {
    
    var sut: RealPushNotificationsHandler!

    func test_isCenterDelegate() {
        let mockedHandler = MockedDeepLinksHandler(expected: [])
        sut = RealPushNotificationsHandler(deepLinksHandler: mockedHandler)
        let center = UNUserNotificationCenter.current()
        XCTAssertTrue(center.delegate === sut)
        mockedHandler.verify()
    }

    func test_emptyPayload() {
        let mockedHandler = MockedDeepLinksHandler(expected: [])
        sut = RealPushNotificationsHandler(deepLinksHandler: mockedHandler)
        let exp = XCTestExpectation(description: #function)
        sut.handleNotification(userInfo: [:]) {
            mockedHandler.verify()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_deepLinkPayload() {
        let mockedHandler = MockedDeepLinksHandler(expected: [
            .open(.showCountryFlag(alpha3Code: "USA"))
        ])
        sut = RealPushNotificationsHandler(deepLinksHandler: mockedHandler)
        let exp = XCTestExpectation(description: #function)
        let userInfo: [String: Any] = [
            "aps": ["country": "USA"]
        ]
        sut.handleNotification(userInfo: userInfo) {
            mockedHandler.verify()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)
    }
}
