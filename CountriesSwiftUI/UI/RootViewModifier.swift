//
//  RootViewModifier.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 09.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - RootViewAppearance

struct RootViewAppearance: ViewModifier {
    
    @Environment(\.injected) private var injected: DIContainer
    @State private var isActive: Bool = false
    internal let inspection = Inspection<Self>()
    
    func body(content: Content) -> some View {
        content
            .blur(radius: isActive ? 0 : 10)
            .ignoresSafeArea()
            .onReceive(stateUpdate) { self.isActive = $0 }
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
    
    private var stateUpdate: AnyPublisher<Bool, Never> {
        injected.appState.updates(for: \.system.isActive)
    }
}
