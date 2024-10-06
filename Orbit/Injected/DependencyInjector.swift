//
//  DependencyInjector.swift
//  Orbit
//
//  Created by Alexey Naumov on 28.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - DIContainer

struct DIContainer: EnvironmentKey {

    let appState: Store<AppState>
    let services: Services

    static var defaultValue: Self { Self.default }

    private static let `default` = DIContainer(appState: AppState(), services: .stub)

    init(appState: Store<AppState>, services: DIContainer.Services) {
        self.appState = appState
        self.services = services
    }

    init(appState: AppState, services: DIContainer.Services) {
        self.init(appState: Store(appState), services: services)
    }
}

extension EnvironmentValues {
    var injected: DIContainer {
        get { self[DIContainer.self] }
        set { self[DIContainer.self] = newValue }
    }
}

#if DEBUG
    extension DIContainer {
        static var preview: Self {
            .init(appState: AppState.preview, services: .stub)
        }
    }
#endif
