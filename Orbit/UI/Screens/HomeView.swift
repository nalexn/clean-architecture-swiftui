//
//  HomeView.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-07.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

import AppwriteModels
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    @FocusState private var focusedTextField: FormTextField?
    @State private var users: [UserModel] = []

    enum FormTextField {
        case title, description
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Add Ideas")
                .font(.title2)
                .fontWeight( /*@START_MENU_TOKEN@*/.bold /*@END_MENU_TOKEN@*/)
                .padding(10)
            Form {

            }.frame(height: 200)

            List {
                Section(header: Text("Users")) {
                    ForEach(
                        $userVM.users
                    ) { $user in
                        HStack(alignment: .center, spacing: 10) {
                            VStack(alignment: .leading) {
                                Text(user.name)
                                    .font(.headline)
                                    .padding(.bottom, 1)

                                InterestsHorizontalTags(
                                    interests: (user.interests ?? [])
                                )
                            }
                        }
                    }
                }
            }

        }
        .navigationBarItems(trailing: self.logoutButton)
        .task {
            await userVM.initialize()
        }
    }
    private var logoutButton: some View {
        Button("Logout") {
            Task {
                await authVM.logout()
            }

        }
    }
}

// Preview provider
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            //            .environmentObject(UserViewModel())
            .environmentObject(AuthViewModel())
        //            .environmentObject(Router())
    }
}
