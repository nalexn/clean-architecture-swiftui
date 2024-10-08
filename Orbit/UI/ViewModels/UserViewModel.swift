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
    //    @Published var currentUser: UserDocument
    @Published var users: [UserModel] = [] {
        didSet {
            print("Users updated: \(users)")

        }
    }
    @Published var error: String? {
        didSet {
            print("Error: \(error ?? "nil")")
        }
    }
    @Published var isLoading = true

    private var userManagementService: UserManagementServiceProtocol =
        UserManagementService()

    @MainActor
    func initialize() async {
        await self.listUsers()
    }

    @MainActor
    func createUser(userData: UserModel) async {
        do {
            let newUser = try await userManagementService.createUser(userData)
            print("User created: \(newUser)")
            await self.listUsers()  // Refresh the user list after creation
        } catch {
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func getUser(id: String) async {
        do {
            let user = try await userManagementService.getUser(id: id)
            print("Retrieved user: \(user)")
            // Handle the retrieved user as needed
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
            await self.listUsers()  // Refresh the user list after update
        } catch {
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func deleteUser(id: String) async {
        do {
            try await userManagementService.deleteUser(id: id)
            print("User deleted: \(id)")
            await self.listUsers()  // Refresh the user list after deletion
        } catch {
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func listUsers(queries: [String]? = nil) async -> [UserModel]? {
        do {
            let userDocuments = try await userManagementService.listUsers(
                queries: queries)
            self.users = userDocuments.map({ $0.data })
            return self.users
        } catch {
            self.error = error.localizedDescription
        }
        return nil
    }
}
