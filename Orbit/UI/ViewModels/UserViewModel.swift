//
//  UserViewModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-07.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

@preconcurrency import Appwrite
import Foundation
import JSONCodable
import SwiftUI

class UserViewModel: ObservableObject {
    @Published var users: [UserModel] = []
    @Published var error: String?
    @Published var isLoading = false
    @Published var searchText: String = ""

    private var userManagementService: UserManagementServiceProtocol =
        UserManagementService()

    @MainActor
    func initialize() async {
        await listUsers()
    }

    @MainActor
    func createUser(userData: UserModel) async {
        do {
            let newUser = try await userManagementService.createUser(userData)
            print("User created: \(newUser)")
            await listUsers()  // Refresh the user list after creation
        } catch {
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func updateUser(id: String, updatedUser: UserModel) async {
        do {
            let updatedUserDocument =
                try await userManagementService.updateUser(
                    id: id, updatedUser: updatedUser)
            print("User updated: \(updatedUserDocument)")
            await listUsers()  // Refresh the user list after update
        } catch {
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func deleteUser(id: String) async {
        do {
            try await userManagementService.deleteUser(id: id)
            print("User deleted: \(id)")
            await listUsers()  // Refresh the user list after deletion
        } catch {
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func listUsers(queries: [String]? = nil) async {
        isLoading = true
        do {
            let userDocuments = try await userManagementService.listUsers(
                queries: queries)
            self.users = userDocuments.map({ $0.data })
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    // Filter users based on search text
    var filteredUsers: [UserModel] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { user in
                user.name.lowercased().contains(searchText.lowercased())
                    || (user.interests?.joined(separator: " ").lowercased()
                        .contains(searchText.lowercased()) ?? false)
            }
        }
    }
}
