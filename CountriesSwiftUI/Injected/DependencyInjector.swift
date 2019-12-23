//
//  DependencyInjector.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 28.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI
import Combine

struct DIContainer: EnvironmentKey {
    
    let appState: Subject<AppState>
    let interactors: Interactors
    
    static var defaultValue: Self { Self.default }
    
    private static let `default` = Self(appState: .init(AppState()),
                                        interactors: .stub)
}

extension EnvironmentValues {
    var injected: DIContainer {
        get { self[DIContainer.self] }
        set { self[DIContainer.self] = newValue }
    }
}

extension DIContainer {
    struct Injector: ViewModifier {
        
        let container: DIContainer
        
        init(container: DIContainer) {
            self.container = container
        }
        
        func body(content: Content) -> some View {
            content
                .environment(\.injected, container)
        }
    }
}

extension DIContainer.Injector {
    static var preview: Self {
        .init(container: .init(appState: .init(AppState.preview),
                               interactors: .stub))
    }
}
