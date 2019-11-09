//
//  DependencyInjector.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 28.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI

struct DependencyInjector: ViewModifier {
    
    let appState: AppState
    let interactors: InteractorsContainer
    
    init(appState: AppState, interactors: InteractorsContainer) {
        self.appState = appState
        self.interactors = interactors
    }
    
    func body(content: Content) -> some View {
        content
            .environment(\.interactors, interactors)
            .environmentObject(appState)
    }
}
