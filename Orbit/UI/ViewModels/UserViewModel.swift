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
    @Published var selectedInterests: [String] = []

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

    // Aggregate unique interests from all users
    var allInterests: [String] {
        let interestsArray = users.compactMap { $0.interests }.flatMap { $0 }
        return Array(Set(interestsArray)).sorted()
    }

    // Filter users based on selected interests and search text
    var filteredUsers: [UserModel] {
        let usersFilteredBySearch =
            searchText.isEmpty
            ? users
            : users.filter { user in
                user.name.lowercased().contains(searchText.lowercased())
                    || (user.interests?.joined(separator: " ").lowercased()
                        .contains(searchText.lowercased()) ?? false)
            }

        if selectedInterests.isEmpty {
            return usersFilteredBySearch
        } else {
            return usersFilteredBySearch.filter { user in
                guard let userInterests = user.interests else { return false }
                return !Set(userInterests).intersection(Set(selectedInterests))
                    .isEmpty
            }
        }
    }

    @MainActor
    func listUsers(queries: [String]? = nil) async {
        isLoading = true
        do {
            let userDocuments = try await userManagementService.listUsers(
                queries: queries)
            self.users = userDocuments.map { $0.data }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    // Function to handle interest selection
    func toggleInterest(_ interest: String) {
        if let index = selectedInterests.firstIndex(of: interest) {
            selectedInterests.remove(at: index)
        } else {
            selectedInterests.append(interest)
        }
    }

}
