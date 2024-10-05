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
    
    @ObservedObject private(set) var viewModel: ViewModel
    internal let inspection = Inspection<Self>()
    
    func body(content: Content) -> some View {
        content
            .blur(radius: viewModel.isActive ? 0 : 10)
            .ignoresSafeArea()
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
}

extension RootViewAppearance {
    class ViewModel: ObservableObject {
        
        @Published var isActive: Bool = false
        private let cancelBag = CancelBag()
        
        init(container: DIContainer) {
            container.appState.map(\.system.isActive)
                .removeDuplicates()
                .weakAssign(to: \.isActive, on: self)
                .store(in: cancelBag)
        }
    }
}
