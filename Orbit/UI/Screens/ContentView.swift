//
//  ContentView.swift
//  Orbit
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - View

struct ContentView: View {
    @ObservedObject private(set) var viewModel: ViewModel

    @ObservedObject var authVM = AuthViewModel()
    @ObservedObject var userVM = UserViewModel()

    @State var isOneSecondAfterLaunch = false
    //    init(viewModel: ViewModel) {
    //        self.viewModel = viewModel
    //        _authVM =
    //            StateObject(
    //                wrappedValue: AuthViewModel(
    //                    viewModel.container.services.accountManagementService
    //                )
    //            )
    //    }

    var body: some View {
        NavigationView {
            ZStack {
                if authVM.isLoading {
                    // Show a loading indicator while checking login status
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.opacity.combined(with: .scale))  // Loading transition
                }
                if authVM.isLoggedIn {
                    //                    CountriesList(
                    //                        viewModel: .init(container: viewModel.container)
                    //                    )
                    //                    .attachEnvironmentOverrides(
                    //                        onChange: viewModel.onChangeHandler
                    //                    )
                    //                    .modifier(
                    //                        RootViewAppearance(
                    //                            viewModel: .init(container: viewModel.container))
                    //                    )
                    //                    .transition(
                    //                        .move(edge: .trailing)
                    //                    )
                    MainTabView()
                        .environmentObject(authVM)
                        .environmentObject(userVM)
                }
                if !authVM.isLoggedIn && !authVM.isLoading {

                    LoginView()
                        //                            .transition(.move(edge: .leading))  // Regular transition
                        .transition(
                            .asymmetric(
                                insertion: isOneSecondAfterLaunch
                                    ? .move(edge: .leading) : .scale,
                                removal: .move(edge: .leading))
                        )  // Asymmetric transition

                        .environmentObject(authVM)
                        .environmentObject(userVM)

                }
            }.animation(
                .easeInOut, value: authVM.isLoggedIn || authVM.isLoading)
        }.onAppear {
            Task {
                await authVM.initialize()
                // wait for 1 second
                try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
                isOneSecondAfterLaunch = true
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
