//
//  AuthViewModel.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-06.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

@preconcurrency import Appwrite
import Foundation
import JSONCodable
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false {
        didSet {
            print("isLoggedIn: \(isLoggedIn)")
        }

    }
    @Published var error: String? {
        didSet {
            print("error: \(error ?? "nil")")
        }
    }
    @Published var user: User<[String: AnyCodable]>?
    @Published var isLoading = true

    private var account: AccountManagementServiceProtocol =
        AccountManagementService()

    // Initialize with DIContainer
    //    init(_ account: AccountManagementServiceProtocol) {
    //        self.account = account
    //    }
    //    static let shared = AuthViewModel()

    @MainActor
    func initialize() async {
        //        #if DEBUG
        //        do {
        //            try await account.deleteSessions()
        //        } catch {
        //            self.error = error.localizedDescription
        //        }
        //        #endif
        await self.getAccount()
    }

    @MainActor
    private func getAccount() async {
        do {
            // Await the result of the async getAccount call
            let user = try await account.getAccount()
            print("4")
            DispatchQueue.main.async {
                print("5")
                self.user = user
                self.isLoggedIn = true
            }
        } catch {
            // Handle the error case
            self.error = error.localizedDescription
            self.isLoggedIn = false
        }
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }

    @MainActor
    func create(name: String, email: String, password: String) async -> User<
        [String: AnyCodable]
    >? {
        do {
            // Await the result of the async getAccount call
            let newUser = try await account.createAccount(email, password, name)
            print("newUser: \(newUser.email)")
            if newUser.email == email {
                print()
                await self.login(email: email, password: password)
                return newUser
            }
        } catch {
            // Handle the error case
            self.error = error.localizedDescription
            self.isLoggedIn = false
        }
        return nil
    }

    @MainActor
    func logout() async {
        do {
            try await account.deleteSession()
            self.isLoggedIn = false
            self.error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func loginAnonymous() async {
        do {
            try await account.createAnonymousSession()
            await self.getAccount()
        } catch {
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func login(email: String, password: String) async {
        do {
            print("1")
            try await account.createSession(email, password)
            print("2")
            await self.getAccount()
            print("3")
        } catch {
            self.error = error.localizedDescription
        }
    }

}
