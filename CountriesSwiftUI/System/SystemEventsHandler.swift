//
//  SystemEventsHandler.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 27.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import UIKit

protocol SystemEventsHandlerProtocol {
    func sceneOpenURLContexts(_ urlContexts: Set<UIOpenURLContext>)
    func sceneDidBecomeActive()
    func sceneWillResignActive()
}

struct SystemEventsHandler: SystemEventsHandlerProtocol {
    
    let appState: AppState
    
    func sceneOpenURLContexts(_ urlContexts: Set<UIOpenURLContext>) {
        guard let url = urlContexts.first?.url else { return }
        handle(url: url)
    }
    
    func handle(url: URL) {
        guard let deelLink = parseDeepLink(url: url) else { return }
        switch deelLink {
        case let .showCountryFlag(alpha3Code):
            appState.routing.countriesList.countryDetails = alpha3Code
            appState.routing.countryDetails.detailsSheet = true
        }
    }
    
    func sceneDidBecomeActive() {
        appState.system.isActive = true
    }
    
    func sceneWillResignActive() {
        appState.system.isActive = false
    }
}

// MARK: - Deep Links

private extension SystemEventsHandler {
    enum DeepLink {
        case showCountryFlag(alpha3Code: Country.Code)
    }
    
    func parseDeepLink(url: URL) -> DeepLink? {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            components.host == "www.example.com",
            let query = components.queryItems
            else { return nil }
        if let item = query.first(where: { $0.name == "alpha3code" }),
            let alpha3Code = item.value {
            return .showCountryFlag(alpha3Code: Country.Code(alpha3Code))
        }
        return nil
    }
}
