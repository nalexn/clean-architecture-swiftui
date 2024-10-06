//
//  AroundMeView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-05.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

import SwiftUI
import Combine
import EnvironmentOverrides

// MARK: - View

struct AroundMeView: View {
    
    @ObservedObject private(set) var viewModel: ViewModel
    
    var body: some View {
        Group {
            if viewModel.isRunningTests {
                Text("Running unit tests")
            } else {
                CountriesList(viewModel: .init(container: viewModel.container))
                    .attachEnvironmentOverrides(onChange: viewModel.onChangeHandler)
                    .modifier(RootViewAppearance(viewModel: .init(container: viewModel.container)))
            }
        }
    }
}

// MARK: - ViewModel

extension AroundMeView {
    class ViewModel: ObservableObject {
        
        let container: DIContainer
        let isRunningTests: Bool
        
        init(container: DIContainer, isRunningTests: Bool = ProcessInfo.processInfo.isRunningTests) {
            self.container = container
            self.isRunningTests = isRunningTests
        }
        
        var onChangeHandler: (EnvironmentValues.Diff) -> Void {
            return { diff in
                if !diff.isDisjoint(with: [.locale, .sizeCategory]) {
                    self.container.appState[\.routing] = AppState.ViewRouting()
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct AroundMeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentView.ViewModel(container: .preview))
    }
}
#endif
