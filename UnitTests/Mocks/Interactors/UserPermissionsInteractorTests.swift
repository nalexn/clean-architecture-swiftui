//
//  UserPermissionsInteractorTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 26.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import Testing
import Combine
import UserNotifications
@testable import CountriesSwiftUI

@Suite struct UserPermissionsInteractorTests {

    @Test func noSideEffectOnInit() async throws {
        let state = Store<AppState>(AppState())
        let notificationsCenter = MockedSystemPushNotifications(expected: [])
        let sut = makeSUT(state: state, notificationsCenter: notificationsCenter)
        try await SuspendingClock().sleep(for: .seconds(0.5))
        #expect(state.value == AppState())
        notificationsCenter.verify()
        _ = sut
    }
    
    // MARK: - Push
    
    @Test func pushFirstResolveStatus() async throws {
        #expect(AppState().permissions.push == .unknown)
        let state = Store<AppState>(AppState())
        let notificationsCenter = MockedSystemPushNotifications(expected: [
            .currentSettings
        ])
        notificationsCenter.getResponses = [.init(authorizationStatus: .authorized)]
        let sut = makeSUT(state: state, notificationsCenter: notificationsCenter)
        sut.resolveStatus(for: .pushNotifications)
        try await SuspendingClock().sleep(for: .seconds(1))
        #expect(state.value.permissions.push == .granted)
        notificationsCenter.verify()
    }
    
    @Test func pushRequestPermissionGrant() async throws {
        let state = Store<AppState>(AppState())
        state[\.permissions.push] = .notRequested
        let notificationsCenter = MockedSystemPushNotifications(expected: [
            .requestAuthorization([.alert, .sound])
        ])
        notificationsCenter.requestResponses = [.success(true)]
        let sut = makeSUT(state: state, notificationsCenter: notificationsCenter)
        sut.request(permission: .pushNotifications)
        try await SuspendingClock().sleep(for: .seconds(0.5))
        #expect(state.value.permissions.push == .granted)
        notificationsCenter.verify()
    }

    @Test func pushRequestPermissionDeny() async throws {
        let state = Store<AppState>(AppState())
        state[\.permissions.push] = .notRequested
        let notificationsCenter = MockedSystemPushNotifications(expected: [
            .requestAuthorization([.alert, .sound])
        ])
        notificationsCenter.requestResponses = [.failure(NSError.test)]
        let sut = makeSUT(state: state, notificationsCenter: notificationsCenter)
        sut.request(permission: .pushNotifications)
        try await SuspendingClock().sleep(for: .seconds(0.5))
        #expect(state.value.permissions.push == .denied)
        notificationsCenter.verify()
    }

    @Test func pushRequestPermissionDeniedBefore() async throws {
        let state = Store<AppState>(AppState())
        state[\.permissions.push] = .denied
        let exp = TestExpectation()
        let notificationsCenter = MockedSystemPushNotifications(expected: [])
        let sut = makeSUT(state: state, notificationsCenter: notificationsCenter) {
            #expect(state.value.permissions.push == .denied)
            exp.fulfill()
        }
        sut.request(permission: .pushNotifications)
        await exp.fulfillment()
        notificationsCenter.verify()
    }
    
    @Test func authorizationStatusMapping() {
        #expect(UNAuthorizationStatus.notDetermined.map == .notRequested)
        #expect(UNAuthorizationStatus.provisional.map == .notRequested)
        #expect(UNAuthorizationStatus.denied.map == .denied)
        #expect(UNAuthorizationStatus.authorized.map == .granted)
        #expect(UNAuthorizationStatus(rawValue: 10)?.map == .notRequested)
    }
    
    // MARK: - Stub
    
    @Test func stubUserPermissionsInteractor() {
        let sut = StubUserPermissionsInteractor()
        sut.request(permission: .pushNotifications)
        sut.resolveStatus(for: .pushNotifications)
    }

    private func makeSUT(state: Store<AppState>,
                         notificationsCenter: MockedSystemPushNotifications,
                         openAppSettings: (() -> Void)? = nil,
                         sourceLocation: SourceLocation = #_sourceLocation
    ) -> RealUserPermissionsInteractor {
        RealUserPermissionsInteractor(
            appState: state, notificationCenter: notificationsCenter) {
                if let openAppSettings {
                    openAppSettings()
                } else {
                    Issue.record("openAppSettings callback not expected", sourceLocation: sourceLocation)
                }
            }
    }
}
