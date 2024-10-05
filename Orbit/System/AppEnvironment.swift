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
        /*
         To see the deep linking in action:
         
         1. Launch the app in iOS 13.4 simulator (or newer)
         2. Subscribe on Push Notifications with "Allow Push" button
         3. Minimize the app
         4. Drag & drop "push_with_deeplink.apns" into the Simulator window
         5. Tap on the push notification
         
         Alternatively, just copy the code below before the "return" and launch:
         
            DispatchQueue.main.async {
                deepLinksHandler.open(deepLink: .showCountryFlag(alpha3Code: "AFG"))
            }
        */
        let session = configuredURLSession()
        let webRepositories = configuredWebRepositories(session: session)
        let dbRepositories = configuredDBRepositories(appState: appState)
        let services = configuredServices(appState: appState,
                                                dbRepositories: dbRepositories,
                                                webRepositories: webRepositories)
        let diContainer = DIContainer(appState: appState, services: services)
        let deepLinksHandler = RealDeepLinksHandler(container: diContainer)
        let pushNotificationsHandler = RealPushNotificationsHandler(deepLinksHandler: deepLinksHandler)
        let systemEventsHandler = RealSystemEventsHandler(
            container: diContainer, deepLinksHandler: deepLinksHandler,
            pushNotificationsHandler: pushNotificationsHandler,
            pushTokenWebRepository: webRepositories.pushTokenWebRepository)
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
        configuration.urlCache = .shared
        return URLSession(configuration: configuration)
    }
    
    private static func configuredWebRepositories(session: URLSession) -> DIContainer.WebRepositories {
        let countriesWebRepository = RealCountriesWebRepository(
            session: session,
            baseURL: "https://restcountries.com/v2")
        let imageWebRepository = RealImageWebRepository(
            session: session,
            baseURL: "https://ezgif.com")
        let pushTokenWebRepository = RealPushTokenWebRepository(
            session: session,
            baseURL: "https://fake.backend.com")
        return .init(imageRepository: imageWebRepository,
                     countriesRepository: countriesWebRepository,
                     pushTokenWebRepository: pushTokenWebRepository)
    }
    
    private static func configuredDBRepositories(appState: Store<AppState>) -> DIContainer.DBRepositories {
        let persistentStore = CoreDataStack(version: CoreDataStack.Version.actual)
        let countriesDBRepository = RealCountriesDBRepository(persistentStore: persistentStore)
        return .init(countriesRepository: countriesDBRepository)
    }
    
    private static func configuredServices(appState: Store<AppState>,
                                           dbRepositories: DIContainer.DBRepositories,
                                           webRepositories: DIContainer.WebRepositories
    ) -> DIContainer.Services {
        
        let countriesService = RealCountriesService(
            webRepository: webRepositories.countriesRepository,
            dbRepository: dbRepositories.countriesRepository,
            appState: appState)
        
        let imagesService = RealImagesService(
            webRepository: webRepositories.imageRepository)
        
        let userPermissionsService = RealUserPermissionsService(
            appState: appState, openAppSettings: {
                URL(string: UIApplication.openSettingsURLString).flatMap {
                    UIApplication.shared.open($0, options: [:], completionHandler: nil)
                }
            })
        
        return .init(countriesService: countriesService,
                     imagesService: imagesService,
                     userPermissionsService: userPermissionsService)
    }
}

extension DIContainer {
    struct WebRepositories {
        let imageRepository: ImageWebRepository
        let countriesRepository: CountriesWebRepository
        let pushTokenWebRepository: PushTokenWebRepository
    }
    
    struct DBRepositories {
        let countriesRepository: CountriesDBRepository
    }
}
