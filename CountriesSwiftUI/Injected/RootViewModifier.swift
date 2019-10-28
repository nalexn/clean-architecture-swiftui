//
//  RootViewModifier.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 28.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI

struct RootViewModifier: ViewModifier {
    
    let appState: AppState
    let services: ServicesContainer
    
    func body(content: Content) -> some View {
        content
            .environment(\.services, services)
            .environmentObject(appState)
            .modifier(Appearance(appState: appState))
    }
}

private extension RootViewModifier {
    struct Appearance: ViewModifier {
        
        @ObservedObject var appState: AppState
        
        func body(content: Content) -> some View {
            content
                .blur(radius: appState.system.isActive ? 0 : 10)
        }
    }
}
