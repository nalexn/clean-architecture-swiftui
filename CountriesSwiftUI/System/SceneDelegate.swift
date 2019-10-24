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
    private lazy var container: DIContainer = {
        let appState = AppState()
        let session = URLSession.shared
        let countriesService = RealCountriesService(
            session: session, baseURL: "https://restcountries.eu/rest/v2")
        return DIContainer(appState: appState, countriesService: countriesService)
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let contentView = ContentView(container: container)
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
