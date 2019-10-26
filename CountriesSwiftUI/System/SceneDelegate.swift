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

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let (appState, services) = setupEnvironment()
        let contentView = ContentView()
            .environment(\.services, services)
            .environmentObject(appState)
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    private func setupEnvironment() -> (AppState, ServicesContainer) {
        let appState = AppState()
        let session = URLSession.shared
        let countriesService = RealCountriesService(
            session: session,
            baseURL: "https://restcountries.eu/rest/v2",
            appState: appState)
        let services = ServicesContainer(countriesService: countriesService)
        return (appState, services)
    }
}
