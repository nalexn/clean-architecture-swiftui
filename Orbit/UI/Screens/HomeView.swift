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
    @State private var title: String = ""
    @State private var description: String = ""
    @FocusState private var focusedTextField: FormTextField?

    //    init() {
    //        self.title = ""
    //        self.description = ""
    //        let ideasViewModel = IdeasViewModel()
    //        _ideasViewModel = StateObject(wrappedValue: ideasViewModel)
    //
    //    }

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
                Section {
                    TextField("Title", text: $title)
                        .onSubmit { focusedTextField = .description }
                        .submitLabel(.next)

                    TextField(
                        "Description",
                        text: $description,
                        axis: .vertical
                    )
                    .onSubmit { focusedTextField = nil }
                    .submitLabel(.continue)
                    HStack {
                        Spacer()
                        Button(
                            "Add Idea",
                            action: {
                                Task {
                                    //                                    await self.ideasViewModel.addIdea(
                                    //                                        title: self.title,
                                    //                                        description: self.description,
                                    //                                        userId: self.loginViewModel.userId
                                    //                                    )
                                    title = ""
                                    description = ""
                                }
                            }
                        ).buttonStyle(.borderedProminent)
                    }
                }
            }.frame(height: 200)
                .navigationBarItems(trailing: self.logoutButton)

            List {
                Section(header: Text("Ideas")) {
                    //                    ForEach(self.ideasViewModel.ideaItems) { item in
                    //                        HStack(alignment: .center, spacing: 10) {
                    //                            VStack(alignment: .leading) {
                    //                                Text(item.idea.title)
                    //                                    .font(.headline)
                    //                                    .padding(.bottom, 1)
                    //
                    //                                Text(item.idea.description)
                    //                                    .font(.subheadline)
                    //                            }
                    //                            Spacer()
                    //                            Button(
                    //                                "Remove",
                    //                                action: {
                    //                                    Task {
                    //                                        await self.ideasViewModel
                    //                                            .removeIdea(
                    //                                                id: item.id
                    //                                            )
                    //                                    }
                    //                                }
                    //                            )
                    //                            //                            .disabled(authVM.user?.id != userVM.
                    //                            .buttonStyle(.borderedProminent)
                    //                        }
                    //                    }
                }
            }

        }
        //        .task {
        //            await self.ideasViewModel.loadIdeas()
        //        }
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
struct IdeasView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            //            .environmentObject(UserViewModel())
            .environmentObject(AuthViewModel())
        //            .environmentObject(Router())
    }
}
