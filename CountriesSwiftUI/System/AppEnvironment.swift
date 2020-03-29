//
//  AppEnvironment.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 09.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import UIKit
import Combine

struct AppEnvironment {
    let container: DIContainer
    let systemEventsHandler: SystemEventsHandler
}

extension AppEnvironment {
    
    static func bootstrap() -> AppEnvironment {
        let appState = Store<AppState>(AppState())
        /*       Uncomment to see deep linking in action
         
        appState.bulkUpdate { appState in
            appState.routing.countriesList.countryDetails = "AFG"
            appState.routing.countryDetails.detailsSheet = true
        }
        */
        let session = configuredURLSession()
        let webRepositories = configuredWebRepositories(session: session)
        let services = configuredServices(appState: appState, webRepositories: webRepositories)
        let systemEventsHandler = RealSystemEventsHandler(appState: appState)
        let diContainer = DIContainer(appState: appState, services: services)
        return AppEnvironment(container: diContainer,
                              systemEventsHandler: systemEventsHandler)
    }
    
    private static func configuredURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 120
        configuration.waitsForConnectivity = true
        configuration.httpMaximumConnectionsPerHost = 5
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: configuration)
    }
    
    private static func configuredWebRepositories(session: URLSession) -> WebRepositoriesContainer {
        let countriesWebRepository = RealCountriesWebRepository(
            session: session,
            baseURL: "https://restcountries.eu/rest/v2")
        let imageWebRepository = RealImageWebRepository(
            session: session,
            baseURL: "https://ezgif.com")
        return WebRepositoriesContainer(imageRepository: imageWebRepository,
                                        countriesRepository: countriesWebRepository)
    }
    
    private static func configuredServices(appState: Store<AppState>,
                                           webRepositories: WebRepositoriesContainer
    ) -> DIContainer.Services {
        let countriesService = RealCountriesService(
            webRepository: webRepositories.countriesRepository,
            appState: appState)
        let imagesService = RealImagesService(
            webRepository: webRepositories.imageRepository)
        return .init(countriesService: countriesService,
                     imagesService: imagesService)
    }
}

private extension AppEnvironment {
    struct WebRepositoriesContainer {
        let imageRepository: ImageWebRepository
        let countriesRepository: CountriesWebRepository
    }
}
