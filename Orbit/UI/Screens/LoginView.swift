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
}

struct LoginView: View {
    @ObservedObject var viewModel = LoginViewModel()
    @Environment(\<#Root#>.container) private var container: DIContainer // Access the DIContainer


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
                        try await appwrite.onLogin(viewModel.email, viewModel.password)
                        // Handle successful login (e.g., navigate to the main app view)
                    } catch {
                        // Handle login error (e.g., show an alert)
                    }
                }
            }) {
                Text("Login")
            }
            .padding()
            Button(action: {
                Task {
                    do {
                        try await appwrite.onRegister(viewModel.email, viewModel.password)
                        // Handle successful registration (e.g., navigate to the main app view)
                    } catch {
                        // Handle registration error (e.g., show an alert)
                    }
                }
            }) {
                Text("Register")
            }
            .padding()
        }
        .padding()
    }
}
