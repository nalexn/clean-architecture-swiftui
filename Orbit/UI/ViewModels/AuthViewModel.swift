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
    @Published var error: String?
    @Published var user: User<[String: AnyCodable]>?
    private var account: AccountManagementServiceProtocol

    // Initialize with DIContainer
    init(_ account: AccountManagementServiceProtocol) {
        self.account = account
    }
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
            self.user = user
            self.isLoggedIn = true
        } catch {
            // Handle the error case
            self.error = error.localizedDescription
            self.isLoggedIn = false
        }
    }

    @MainActor
    func create(name: String, email: String, password: String) async {
        do {
            // Await the result of the async getAccount call
            let user = try await account.createAccount(email, password, name)
            self.user = user
            self.isLoggedIn = true
        } catch {
            // Handle the error case
            self.error = error.localizedDescription
            self.isLoggedIn = false
        }
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
    public func login(email: String, password: String) async {
        do {
            try await account.createSession(email, password)
            await self.getAccount()
        } catch {
            self.error = error.localizedDescription
        }
    }

}
