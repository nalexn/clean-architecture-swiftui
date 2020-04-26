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
    var interactors: DIContainer.Interactors {
        return sut.container.interactors
    }
    var deepLinksHandler: MockedDeepLinksHandler? {
        return sut.deepLinksHandler as? MockedDeepLinksHandler
    }
    var pushTokenWebRepository: MockedPushTokenWebRepository? {
        return sut.pushTokenWebRepository as? MockedPushTokenWebRepository
    }
    
    func verify(appState: AppState = AppState(), file: StaticString = #file, line: UInt = #line) {
        interactors.verify(file: file, line: line)
        deepLinksHandler?.verify(file: file, line: line)
        pushTokenWebRepository?.verify(file: file, line: line)
        XCTAssertEqual(self.appState, appState, file: file, line: line)
    }

    func setupSut(countries: [MockedCountriesInteractor.Action] = [],
                  permissions: [MockedUserPermissionsInteractor.Action] = [],
                  deepLink: [MockedDeepLinksHandler.Action] = [],
                  pushToken: [MockedPushTokenWebRepository.Action] = []) {
        let interactors = DIContainer.Interactors(
            countriesInteractor: MockedCountriesInteractor(expected: countries),
            imagesInteractor: MockedImagesInteractor(expected: []),
            userPermissionsInteractor: MockedUserPermissionsInteractor(expected: permissions))
        let container = DIContainer(appState: AppState(),
                                    interactors: interactors)
        let deepLinksHandler = MockedDeepLinksHandler(expected: deepLink)
        let pushNotificationsHandler = DummyPushNotificationsHandler()
        let pushTokenWebRepository = MockedPushTokenWebRepository(expected: pushToken)
        sut = RealSystemEventsHandler(container: container,
                                      deepLinksHandler: deepLinksHandler,
                                      pushNotificationsHandler: pushNotificationsHandler,
                                      pushTokenWebRepository: pushTokenWebRepository)
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
    
    #if os(iOS) && !targetEnvironment(macCatalyst)
    func test_keyboardHeight() throws {
        let textFiled = UITextField(frame: .zero)
        let window = try XCTUnwrap(UIApplication.shared.windows.first, "Cannot extract the host view")
        window.makeKeyAndVisible()
        window.addSubview(textFiled)
        setupSut()
        XCTAssertEqual(appState.system.keyboardHeight, 0)
        textFiled.becomeFirstResponder()
        XCTAssertGreaterThan(appState.system.keyboardHeight, 0)
        textFiled.removeFromSuperview()
        verify()
    }
    #endif
    
    func test_handlePushRegistration() {
        setupSut(pushToken: [
            .register(Data())
        ])
        sut.handlePushRegistration(result: .success(Data()))
        verify()
    }
    
    func test_silentRemoteNotification() {
        setupSut(countries: [
            .refreshCountriesList
        ])
        pushTokenWebRepository?.registerTokenResponse = .success(())
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
        return Set([Test(urlString)])
    }
}

private extension UIOpenURLContext {
    final class Test: UIOpenURLContext {
        
        let urlString: String
        override var url: URL { URL(string: urlString)! }
        
        init(_ urlString: String) {
            self.urlString = urlString
        }
    }

}
