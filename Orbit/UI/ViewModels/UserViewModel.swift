//
//  UserViewModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-07.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

@preconcurrency import Appwrite
import CoreLocation
import Foundation
import JSONCodable
import SwiftUI

class UserViewModel: NSObject, ObservableObject, LocationManagerDelegate {

    @Published var users: [UserModel] = []
    @Published var error: String?
    @Published var isLoading = false
    @Published var searchText: String = ""
    @Published var selectedInterests: [String] = []
    @Published var currentLocation: CLLocationCoordinate2D?

    private var userManagementService: UserManagementServiceProtocol =
        UserManagementService()
    private var appwriteRealtimeClient = AppwriteService.shared.realtime
    private var locationManager: LocationManager

    init(locationManager: LocationManager = LocationManager()) {
        self.locationManager = locationManager
        super.init()
        locationManager.delegate = self  // Set delegate to receive location updates
        locationManager.locationManager.startUpdatingLocation()  // Start location updates
    }

    @MainActor
    func initialize() async {
        await listUsers()
        await subscribeToRealtimeUpdates()

    }

    @MainActor
    func createUser(userData: UserModel) async {
        do {
            let newUser = try await userManagementService.createUser(userData)
            print("User created: \(newUser)")
            await listUsers()  // Refresh the user list after creation
        } catch {
            print("Source: createUser - \(error.localizedDescription)")
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func updateUser(id: String, updatedUser: UserModel) async {
        do {
            let updatedUserDocument =
                try await userManagementService.updateUser(
                    accountId: id, updatedUser: updatedUser)
            await listUsers()  // Refresh the user list after update
        } catch {
            print("Source: updateUser - \(error.localizedDescription)")
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func deleteUser(id: String) async {
        do {
            try await userManagementService.deleteUser(id)
            print("User deleted: \(id)")
            await listUsers()  // Refresh the user list after deletion
        } catch {
            self.error = error.localizedDescription
            print("Source: deleteUser - \(error.localizedDescription)")
        }
    }

    // Aggregate unique interests from all users
    var allInterests: [String] {
        let interestsArray = users.compactMap { $0.interests }.flatMap { $0 }
        return Array(Set(interestsArray)).sorted()
    }

    // Filter users based on selected interests and search text
    var filteredUsers: [UserModel] {
        // Filter by search text
        let usersFilteredBySearch =
            searchText.isEmpty
            ? users
            : users.filter { user in
                user.name.lowercased().contains(searchText.lowercased())
                    || (user.interests?.joined(separator: " ").lowercased()
                        .contains(searchText.lowercased()) ?? false)
            }

        // Filter by interests
        let usersFilteredByInterests: [UserModel]
        if selectedInterests.isEmpty {
            usersFilteredByInterests = usersFilteredBySearch
        } else {
            usersFilteredByInterests = usersFilteredBySearch.filter { user in
                guard let userInterests = user.interests else { return false }
                return !Set(userInterests).intersection(Set(selectedInterests))
                    .isEmpty
            }
        }

        return usersNearby(users: usersFilteredByInterests)

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
            print("Source: listUsers - \(error.localizedDescription)")
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

    // MARK - Location
    // LocationManagerDelegate method
    func didUpdateLocation(latitude: Double, longitude: Double) {
        self.currentLocation = CLLocationCoordinate2D(
            latitude: latitude, longitude: longitude)
        Task {
            await updateCurrentUserLocation(
                latitude: latitude, longitude: longitude)
        }
    }

    // Update current user's location in the database
    @MainActor
    func updateCurrentUserLocation(latitude: Double, longitude: Double) async {

        do {
            guard
                let currentUser =
                    try await userManagementService.getCurrentUser()
            else {
                print("Current user not found. Anonymous login?")
                return
            }
            var updatedUser = currentUser
            updatedUser.latitude = latitude
            updatedUser.longitude = longitude

            await updateUser(
                id: currentUser.accountId, updatedUser: updatedUser)
        } catch {
            print("Source: updateCurrentUserLocation - \(error.localizedDescription)")
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func subscribeToRealtimeUpdates() async {
        do {
            let subscription = try await appwriteRealtimeClient.subscribe(
                channels: [
                    "databases.\(AppwriteService.shared.databaseId).collections.users.documents"
                ]) { event in
                    if let payload = event.payload {
                        Task {
                            let updatedUser = try JSONDecoder().decode(
                                UserModel.self,
                                from: JSONSerialization.data(
                                    withJSONObject: payload))
                            self.handleRealtimeUserUpdate(updatedUser)
                        }
                    }
                }
        } catch {
            self.error = error.localizedDescription
            print(
                "Error decoding user data: \(error.localizedDescription)"
            )
        }
    }

    @MainActor
    func handleRealtimeUserUpdate(_ updatedUser: UserModel) {
        if let index = users.firstIndex(where: { $0.id == updatedUser.id }) {
            users[index] = updatedUser
        } else {
            users.append(updatedUser)
        }
    }

    // Helper function to filter users by location proximity
    func usersNearby(users: [UserModel], radius: Double = 10000) -> [UserModel] {
        guard let currentLocation = currentLocation else {
            print("user location not available")
            return []
        }
        print("currentUserLocation: \(currentLocation)")
        return users.filter { user in
            guard let userLat = user.latitude, let userLong = user.longitude
            else { return false }
            print("userLat: \(userLat), userLong: \(userLong)")
            let userLocation = CLLocation(
                latitude: Double(userLat), longitude: Double(userLong))
            let currentCLLocation = CLLocation(
                latitude: currentLocation.latitude,
                longitude: currentLocation.longitude)
            let distanceFromEachOther = currentCLLocation.distance(
                from: userLocation)
            print("distance: \(distanceFromEachOther)")
            return distanceFromEachOther <= radius
        }
    }
}
