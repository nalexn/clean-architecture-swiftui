//
//  RootViewModifier.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 09.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI

// MARK: - State Updates Filtering

private extension RootViewAppearance {
    struct StateSnapshot: Equatable {
        let isAppActive: Bool
    }
}

private extension AppState {
    var rootViewStateSnapshot: RootViewAppearance.StateSnapshot {
        .init(isAppActive: system.isActive)
    }
}

// MARK: - RootViewAppearance

struct RootViewAppearance: ViewModifier {
    
    @ObservedObject private var appState: Deduplicated<AppState, StateSnapshot>
    
    init(appState: AppState) {
        self.appState = appState.deduplicated { $0.rootViewStateSnapshot }
    }
    
    func body(content: Content) -> some View {
        content
            .blur(radius: appState.system.isActive ? 0 : 10)
    }
}
