//
//  DIContainer.swift
//  CountriesSwiftUI
//
//  Created by Alexey on 7/11/24.
//  Copyright © 2024 Alexey Naumov. All rights reserved.
//

import SwiftUI
import SwiftData

struct DIContainer {

    let appState: Store<AppState>
    let interactors: Interactors

    init(appState: Store<AppState> = .init(AppState()), interactors: Interactors) {
        self.appState = appState
        self.interactors = interactors
    }

    init(appState: AppState, interactors: Interactors) {
        self.init(appState: Store<AppState>(appState), interactors: interactors)
    }
}

extension DIContainer {
    struct WebRepositories {
        let images: ImagesWebRepository
        let countries: CountriesWebRepository
        let pushToken: PushTokenWebRepository
    }
    struct DBRepositories {
        let countries: CountriesDBRepository
    }
    struct Interactors {
        let images: ImagesInteractor
        let countries: CountriesInteractor
        let userPermissions: UserPermissionsInteractor

        static var stub: Self {
            .init(images: StubImagesInteractor(),
                  countries: StubCountriesInteractor(),
                  userPermissions: StubUserPermissionsInteractor())
        }
    }
}

extension EnvironmentValues {
    @Entry var injected: DIContainer = DIContainer(appState: AppState(), interactors: .stub)
}

extension View {
    func inject(_ container: DIContainer) -> some View {
        return self
            .environment(\.injected, container)
    }
}
