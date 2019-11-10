//
//  AppEnvironment.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 09.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import UIKit

struct AppEnvironment {
    let appState: AppState
    let interactors: InteractorsContainer
    let systemEventsHandler: SystemEventsHandler
    let dependencyInjector: DependencyInjector
}

extension AppEnvironment {
    
    static func bootstrap() -> AppEnvironment {
        let appState = AppState()
        let session = configuredURLSession()
        let webRepositories = configuredWebRepositories(session: session)
        let interactors = configuredInteractors(appState: appState, webRepositories: webRepositories)
        let systemEventsHandler = RealSystemEventsHandler(appState: appState)
        let dependencyInjector = DependencyInjector(appState: appState, interactors: interactors)
        return AppEnvironment(appState: appState, interactors: interactors,
                              systemEventsHandler: systemEventsHandler,
                              dependencyInjector: dependencyInjector)
    }
    
    private static func configuredURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
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
    
    private static func configuredInteractors(appState: AppState,
                                              webRepositories: WebRepositoriesContainer
    ) -> InteractorsContainer {
        let countriesInteractor = RealCountriesInteractor(
            webRepository: webRepositories.countriesRepository,
            appState: appState)
        let inMemoryCache = ImageMemCacheRepository()
        let memoryWarning = NotificationCenter.default
            .publisher(for: UIApplication.didReceiveMemoryWarningNotification)
            .map { _ in }.eraseToAnyPublisher()
        let imagesInteractor = RealImagesInteractor(
            webRepository: webRepositories.imageRepository,
            inMemoryCache: inMemoryCache,
            memoryWarning: memoryWarning,
            appState: appState)
        return InteractorsContainer(countriesInteractor: countriesInteractor,
                                    imagesInteractor: imagesInteractor)
    }
}

private extension AppEnvironment {
    struct WebRepositoriesContainer {
        let imageRepository: ImageWebRepository
        let countriesRepository: CountriesWebRepository
    }
}
