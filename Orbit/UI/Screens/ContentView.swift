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

    @State private var isLoggedIn: Bool = false  // Track login state

    var body: some View {
        NavigationView {
//            Group {
                if isLoggedIn {
                    // Show the main app content (e.g., CountriesList)
                    CountriesList(viewModel: .init(container: viewModel.container))
                        .attachEnvironmentOverrides(onChange: viewModel.onChangeHandler)
                        .modifier(
                            RootViewAppearance(viewModel: .init(container: viewModel.container)))
                } else {
                    // Show the login view
                    LoginView()  // Pass your Appwrite instance
                }
//            }
        }.onAppear {
            // Check if the user is already logged in
            checkLoginStatus()
        }
    }

    private func checkLoginStatus() {
        // Implement logic to check if the user is logged in
        // Update isLoggedIn accordingly
    }
}

// MARK: - ViewModel

extension ContentView {
    class ViewModel: ObservableObject {

        let container: DIContainer
        let isRunningTests: Bool

        init(container: DIContainer, isRunningTests: Bool = ProcessInfo.processInfo.isRunningTests)
        {
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
