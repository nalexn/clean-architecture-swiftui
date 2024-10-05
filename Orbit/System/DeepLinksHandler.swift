//
//  DeepLinksHandler.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 26.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import Foundation

enum DeepLink: Equatable {
    
    case showCountryFlag(alpha3Code: Country.Code)
    
    init?(url: URL) {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            components.host == "www.example.com",
            let query = components.queryItems
            else { return nil }
        if let item = query.first(where: { $0.name == "alpha3code" }),
            let alpha3Code = item.value {
            self = .showCountryFlag(alpha3Code: Country.Code(alpha3Code))
            return
        }
        return nil
    }
}

// MARK: - DeepLinksHandler

protocol DeepLinksHandler {
    func open(deepLink: DeepLink)
}

struct RealDeepLinksHandler: DeepLinksHandler {
    
    private let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func open(deepLink: DeepLink) {
        switch deepLink {
        case let .showCountryFlag(alpha3Code):
            let routeToDestination = {
                self.container.appState.bulkUpdate {
                    $0.routing.countriesList.countryDetails = alpha3Code
                    $0.routing.countryDetails.detailsSheet = true
                }
            }
            /*
             SwiftUI is unable to perform complex navigation involving
             simultaneous dismissal or older screens and presenting new ones.
             A work around is to perform the navigation in two steps:
             */
            let defaultRouting = AppState.ViewRouting()
            if container.appState.value.routing != defaultRouting {
                self.container.appState[\.routing] = defaultRouting
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: routeToDestination)
            } else {
                routeToDestination()
            }
        }
    }
}
