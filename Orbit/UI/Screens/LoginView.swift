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
    @State private var email = ""
    @State private var password = ""
    @State private var isActiveSignup = false

    @ObservedObject var authVM: AuthViewModel = AuthViewModel()

    var body: some View {

        NavigationStack {
            AppwriteLogo {
                VStack {
                    // Declare a NavigationLink with a value that matches your navigationDestination
                    // Replace the old NavigationLink with navigationDestination
                    //                    navigationDestination(isPresented: $isActiveSignup) {
                    //                        SignupView() // Show SignupView when
                    //                    }
                    // Declare a NavigationLink with a value that matches your navigationDestination
                    NavigationLink(
                        value: "signup",
                        label: {
                            EmptyView()  // Same effect as before
                        }
                    )
                    .navigationDestination(for: String.self) { value in
                        // Define the destination based on the value
                        if value == "signup" {
                            SignupView()  // Show SignupView when value is "signup"
                        }
                    }
                    HStack {
                        Text("Welcome back to\nFlAppwrite Jobs")
                            .largeSemiBoldFont()
                            .padding(.top, 60)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    Spacer().frame(height: 10)
                    HStack {
                        Text("Let's sign in.")
                            .largeLightFont()
                        Spacer()
                    }
                    .padding(.bottom, 30)

                    TextField("E-mail", text: self.$email)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(16.0)

                    SecureField("Password", text: self.$password)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(16.0)

                    Spacer().frame(height: 16)

                    Button("Login") {
                        Task {
                            await authVM.login(email: email, password: password)
                        }
                    }
                    .regularFont()
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.pink)
                    .cornerRadius(16.0)

                    HStack {
                        Text("Anonymous Login")
                            .onTapGesture {
                                Task {
                                    await authVM.loginAnonymous()
                                }
                            }
                        Text(".")
                        Text("Signup")
                            .onTapGesture {
                                isActiveSignup = true
                            }
                    }
                    .regularFont()
                    .padding(.top, 30)
                    Spacer()

                }
                .foregroundColor(.white)
                .padding([.leading, .trailing], 40)

            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .preferredColorScheme(.dark)
    }
}
