//
//  LoginView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-05.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var feedback: String = "init"
}

struct LoginView: View {
    @ObservedObject var viewModel = LoginViewModel()
    @Environment(\.injected) private var injected: DIContainer  // Access the DIContainer

    var body: some View {
        VStack {
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: {
                Task {
                    do {
                        let response = try await injected.services.accountManagementService
                            .createSession(viewModel.email, viewModel.password)
                        // Handle successful login (e.g., navigate to the main app view)
                        if response.userId != nil {
                            // Navigate to the main app view
                            viewModel.feedback = "Login successful"
                        } else {
                            viewModel.feedback = "Login failed"
                        }
                    } catch {
                        // Handle login error (e.g., show an alert)
                        viewModel.feedback = "Login failed"
                    }
                }
            }) {
                Text("Login")
            }
            .padding()
            Button(action: {
                Task {
                    do {
                        let response = try await injected.services.accountManagementService
                            .createAccount(
                                viewModel.email, viewModel.password)
                        // Handle successful registration (e.g., navigate to the main app view)
                        if response.id != nil {
                            // Navigate to the main app view
                            viewModel.feedback = "Registration successful"
                        } else {
                            viewModel.feedback = "Registration failed"
                        }
                    } catch {
                        // Handle registration error (e.g., show an alert)
                        viewModel.feedback = "Registration failed"
                    }
                }
            }) {
                Text("Register")
            }
            .padding()
            Text(viewModel.feedback)
        }
        .padding()
        .navigationTitle("Login/Sign Up")
    }
}
