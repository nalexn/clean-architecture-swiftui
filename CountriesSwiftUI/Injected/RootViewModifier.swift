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
    }
}
