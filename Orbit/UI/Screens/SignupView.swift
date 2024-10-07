//
//  SignupView.swift
//  Appwrite Jobs
//
//  Created by Damodar Lohani on 11/10/2021.
//

import SwiftUI

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""

    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        AppwriteLogo {
            VStack {
                HStack {
                    Image("back-icon")
                        .resizable()
                        .frame(width: 24, height: 21)
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                    Spacer()
                }
                .padding([.top, .bottom], 30)

                HStack {
                    Text("Join Millions of\n other users!")
                        .largeSemiBoldFont()
                    Spacer()
                }

                Spacer().frame(height: 10)

                HStack {
                    Text("Create an account")
                        .largeLightFont()
                        .padding(.bottom)
                    Spacer()
                }
                .padding(.bottom, 30)

                TextField("Name", text: self.$name)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(16.0)

                TextField("E-mail", text: self.$email)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(16.0)

                SecureField("Password", text: self.$password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(16.0)
                Spacer().frame(height: 16)
                Button("Create account") {
                    Task {
                        await authVM.create(
                            name: name, email: email, password: password)
                    }
                }
                .regularFont()
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 60)
                .background(Color.pink)
                .cornerRadius(16.0)

                Spacer()
            }
            .padding([.leading, .trailing], 27.5)
            .navigationBarHidden(true)
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
            .preferredColorScheme(.dark)
    }
}
