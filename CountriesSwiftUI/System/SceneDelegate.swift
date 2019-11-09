//
//  SceneDelegate.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import UIKit
import SwiftUI
import Foundation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var systemEventsHandler: SystemEventsHandler?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let (appState, interactors, systemEventsHandler) = createDependencies()
        let environment = RootViewModifier(appState: appState, interactors: interactors)
        let contentView = ContentView(environment: environment)
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
        self.systemEventsHandler = systemEventsHandler
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        systemEventsHandler?.sceneOpenURLContexts(URLContexts)
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        systemEventsHandler?.sceneDidBecomeActive()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        systemEventsHandler?.sceneWillResignActive()
    }
}

private extension SceneDelegate {
    func createDependencies() -> (AppState, InteractorsContainer, SystemEventsHandler) {
        let appState = AppState()
        let session = configuredURLSession()
        let countriesWebRepository = RealCountriesWebRepository(
            session: session,
            baseURL: "https://restcountries.eu/rest/v2")
        let imageWebRepository = RealImageWebRepository(
            session: session,
            baseURL: "https://ezgif.com")
        let countriesInteractor = RealCountriesInteractor(
            webRepository: countriesWebRepository,
            appState: appState)
        let imagesInteractor = RealImagesInteractor(
            webRepository: imageWebRepository, appState: appState)
        let interactors = InteractorsContainer(countriesInteractor: countriesInteractor,
                                               imagesInteractor: imagesInteractor)
        let systemEventsHandler = RealSystemEventsHandler(appState: appState)
        return (appState, interactors, systemEventsHandler)
    }
    
    func configuredURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }
}
