//
//  ContentView.swift
//  Orbit
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Combine
import EnvironmentOverrides
import SwiftUI

// MARK: - View

struct ContentView: View {
    @ObservedObject private(set) var viewModel: ViewModel

    @ObservedObject var authVM: AuthViewModel = AuthViewModel()

    var body: some View {
        NavigationView {
            //            Group {
            if authVM.isLoggedIn {
                // Show the main app content (e.g., CountriesList)
                CountriesList(viewModel: .init(container: viewModel.container))
                    .attachEnvironmentOverrides(
                        onChange: viewModel.onChangeHandler
                    )
                    .modifier(
                        RootViewAppearance(
                            viewModel: .init(container: viewModel.container)))
            } else {
                // Show the login view
                LoginView()
                //                        .environmentObject(authVM)
            }
            //            }
        }.onAppear {
            Task {
                await authVM.initialize()
            }
        }
    }
}

// MARK: - ViewModel

extension ContentView {
    class ViewModel: ObservableObject {

        let container: DIContainer
        let isRunningTests: Bool

        init(
            container: DIContainer,
            isRunningTests: Bool = ProcessInfo.processInfo.isRunningTests
        ) {
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
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView(viewModel: ContentView.ViewModel(container: .preview))
        }
    }
#endif
