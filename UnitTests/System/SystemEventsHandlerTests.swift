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

    override func setUp() {
        let interactors = DIContainer.Interactors(
            countriesInteractor: MockedCountriesInteractor(expected: []),
            imagesInteractor: MockedImagesInteractor(expected: []),
            userPermissionsInteractor: MockedUserPermissionsInteractor(expected: []))
        let container = DIContainer(appState: AppState(),
                                    interactors: interactors)
        let deepLinksHandler = MockedDeepLinksHandler(expected: [])
        let pushNotificationsHandler = DummyPushNotificationsHandler()
        let pushTokenWebRepository = MockedPushTokenWebRepository()
        sut = RealSystemEventsHandler(container: container,
                                      deepLinksHandler: deepLinksHandler,
                                      pushNotificationsHandler: pushNotificationsHandler,
                                      pushTokenWebRepository: pushTokenWebRepository)
    }

    func test_didBecomeActive() {
        sut.sceneDidBecomeActive()
        var reference = AppState()
        XCTAssertFalse(reference.system.isActive)
        reference.system.isActive = true
        XCTAssertEqual(sut.appState.value, reference)
    }
    
    func test_willResignActive() {
        sut.sceneDidBecomeActive()
        sut.sceneWillResignActive()
        let reference = AppState()
        XCTAssertEqual(sut.appState.value, reference)
    }

    func test_openURLContexts_countryDeepLink() {
        let countries = Country.mockedData
        let deepLinkURL = "https://www.example.com/?alpha3code=\(countries[0].alpha3Code)"
        let contexts = UIOpenURLContext.contexts(deepLinkURL)
        XCTAssertNil(sut.appState.value.routing.countriesList.countryDetails)
        XCTAssertFalse(sut.appState.value.routing.countryDetails.detailsSheet)
        sut.sceneOpenURLContexts(contexts)
        XCTAssertEqual(sut.appState.value.routing.countriesList.countryDetails, countries[0].alpha3Code)
        XCTAssertTrue(sut.appState.value.routing.countryDetails.detailsSheet)
    }
    
    func test_openURLContexts_randomURL() {
        let url1 = "https://www.example.com/link/?param=USD"
        let contexts1 = UIOpenURLContext.contexts(url1)
        let url2 = "https://www.domain.com/test/?alpha3code=USD"
        let contexts2 = UIOpenURLContext.contexts(url2)
        let reference = AppState()
        sut.sceneOpenURLContexts(contexts1)
        XCTAssertEqual(sut.appState.value, reference)
        sut.sceneOpenURLContexts(contexts2)
        XCTAssertEqual(sut.appState.value, reference)
    }
    
    func test_openURLContexts_emptyContexts() {
        let reference = AppState()
        sut.sceneOpenURLContexts(Set<UIOpenURLContext>())
        XCTAssertEqual(sut.appState.value, reference)
    }
    
    #if os(iOS) && !targetEnvironment(macCatalyst)
    func test_keyboardHeight() throws {
        let textFiled = UITextField(frame: .zero)
        let window = try XCTUnwrap(UIApplication.shared.windows.first, "Cannot extract the host view")
        window.makeKeyAndVisible()
        window.addSubview(textFiled)
        XCTAssertEqual(sut.appState.value.system.keyboardHeight, 0)
        textFiled.becomeFirstResponder()
        XCTAssertGreaterThan(sut.appState.value.system.keyboardHeight, 0)
        textFiled.removeFromSuperview()
    }
    #endif
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

extension RealSystemEventsHandler {
    var appState: Store<AppState> {
        self.container.appState
    }
}
