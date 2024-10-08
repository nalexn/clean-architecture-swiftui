//
//  SignupView.swift
//  Appwrite Jobs
//
//  Created by Damodar Lohani on 11/10/2021.
//

import SwiftUI

struct SignupView: View {
    @State private var email = "iiiii@gmail.com"
    @State private var password = "12345678"
    @State private var name = "Rami"

    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var userVM: UserViewModel
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
                        let newUser = await authVM.create(
                            name: name, email: email, password: password)
                        guard let userId = newUser?.id else {
                            print("Error: User ID is nil")
                            return
                        }
                        let myUser = UserModel(
                            // TODO: Refactor this
                            accountId: userId
                                //                            bio: nil,
                                //                            interests: nil,
                                //                            location: nil,
                                //                            friends: nil,
                                //                            followers: nil,
                                //                            following: nil,
                                //                            profilePictureId: nil,
                                //                            settings: nil
                        )
                        print(myUser.accountId)
                        await userVM
                            .createUser(userData: myUser)
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
