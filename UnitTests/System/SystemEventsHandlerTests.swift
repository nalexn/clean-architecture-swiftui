//
//  SystemEventsHandlerTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 31.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import UIKit
@testable import CountriesSwiftUI

final class SystemEventsHandlerTests: XCTestCase {
    
    var sut: RealSystemEventsHandler!
    
    var appState: AppState {
        return sut.container.appState.value
    }
    var services: DIContainer.Services {
        return sut.container.services
    }
    var deepLinksHandler: MockedDeepLinksHandler? {
        return sut.deepLinksHandler as? MockedDeepLinksHandler
    }
    var pushTokenWebRepository: MockedPushTokenWebRepository? {
        return sut.pushTokenWebRepository as? MockedPushTokenWebRepository
    }
    
    func verify(appState: AppState = AppState(), file: StaticString = #file, line: UInt = #line) {
        services.verify(file: file, line: line)
        deepLinksHandler?.verify(file: file, line: line)
        pushTokenWebRepository?.verify(file: file, line: line)
        XCTAssertEqual(self.appState, appState, file: file, line: line)
    }

    func setupSut(countries: [MockedCountriesService.Action] = [],
                  permissions: [MockedUserPermissionsService.Action] = [],
                  deepLink: [MockedDeepLinksHandler.Action] = [],
                  pushToken: [MockedPushTokenWebRepository.Action] = []) {
        let services = DIContainer.Services(
            countriesService: MockedCountriesService(expected: countries),
            imagesService: MockedImagesService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: permissions))
        let container = DIContainer(appState: AppState(), services: services)
        let deepLinksHandler = MockedDeepLinksHandler(expected: deepLink)
        let pushNotificationsHandler = DummyPushNotificationsHandler()
        let pushTokenWebRepository = MockedPushTokenWebRepository(expected: pushToken)
        sut = RealSystemEventsHandler(container: container,
                                      deepLinksHandler: deepLinksHandler,
                                      pushNotificationsHandler: pushNotificationsHandler,
                                      pushTokenWebRepository: pushTokenWebRepository)
    }
    
    func test_noSideEffectOnInit() {
        setupSut()
        sut.container.appState[\.permissions.push] = .denied
        let reference = sut.container.appState.value
        verify(appState: reference)
    }
    
    func test_subscribesOnPushIfGranted() {
        setupSut(permissions: [
            .request(.pushNotifications)
        ])
        sut.container.appState[\.permissions.push] = .granted
        let reference = sut.container.appState.value
        verify(appState: reference)
    }

    func test_didBecomeActive() {
        setupSut(permissions: [
            .resolveStatus(.pushNotifications)
        ])
        sut.sceneDidBecomeActive()
        var reference = AppState()
        XCTAssertFalse(reference.system.isActive)
        reference.system.isActive = true
        verify(appState: reference)
    }
    
    func test_willResignActive() {
        setupSut(permissions: [
            .resolveStatus(.pushNotifications)
        ])
        sut.sceneDidBecomeActive()
        sut.sceneWillResignActive()
        verify()
    }

    func test_openURLContexts_countryDeepLink() {
        let countries = Country.mockedData
        let code = countries[0].alpha3Code
        let deepLinkURL = "https://www.example.com/?alpha3code=\(code)"
        setupSut(deepLink: [.open(.showCountryFlag(alpha3Code: code))])
        let contexts = UIOpenURLContext.contexts(deepLinkURL)
        sut.sceneOpenURLContexts(contexts)
        verify()
    }
    
    func test_openURLContexts_randomURL() {
        let url1 = "https://www.example.com/link/?param=USD"
        let contexts1 = UIOpenURLContext.contexts(url1)
        let url2 = "https://www.domain.com/test/?alpha3code=USD"
        let contexts2 = UIOpenURLContext.contexts(url2)
        setupSut()
        sut.sceneOpenURLContexts(contexts1)
        sut.sceneOpenURLContexts(contexts2)
        verify()
    }
    
    func test_openURLContexts_emptyContexts() {
        setupSut()
        sut.sceneOpenURLContexts(Set<UIOpenURLContext>())
        verify()
    }
    
    func test_handlePushRegistration() {
        setupSut(pushToken: [
            .register(Data())
        ])
        sut.handlePushRegistration(result: .success(Data()))
        verify()
    }
    
    func test_silentRemoteNotificationSuccess() {
        setupSut(countries: [
            .refreshCountriesList
        ])
        let exp = XCTestExpectation(description: #function)
        sut.appDidReceiveRemoteNotification(payload: [:]) { result in
            XCTAssertEqual(result, .newData)
            self.verify()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)
    }
}

private extension UIOpenURLContext {
    static func contexts(_ urlString: String) -> Set<UIOpenURLContext> {
        UIOpenURLContext.createInstance()
        return Set([Test.create(url: urlString)])
    }
}

private extension UIOpenURLContext {
    final class Test: UIOpenURLContext {
        
        var urlString: String = ""
        override var url: URL { URL(string: urlString)! }
        
        static func create(url: String) -> Test {
            let instance = createInstance()
            instance.urlString = url
            return instance
        }
    }

}
