//
//  RootViewModifier.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 09.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI

struct RootViewAppearance: ViewModifier {
    
    @ObservedObject var appState: AppState
    
    func body(content: Content) -> some View {
        content
            .blur(radius: appState.system.isActive ? 0 : 10)
    }
}
