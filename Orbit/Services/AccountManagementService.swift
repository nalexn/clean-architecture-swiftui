//
//  AccountManagementServiceProtocol.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-05.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

//
//  AccountManagementService.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-05.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

import Appwrite
import Foundation

protocol AccountManagementServiceProtocol {
    func createAccount() async throws -> User
    func getAccount() async throws -> User
    func createSession() async throws -> Session
    func createAnonymousSession() async throws -> Session
    func listSessions() async throws -> [Session]
    func deleteSessions() async throws
    func deleteSession() async throws
    func generateJWT() async throws -> Jwt
    func socialLogin(provider: String) async throws
}

class AccountManagementService: AccountManagementServiceProtocol {
    private let appwriteService: AppwriteService

    init(appwriteService: AppwriteService) {
        self.appwriteService = appwriteService
    }

    public func onRegister(
        _ email: String,
        _ password: String
    ) async throws -> User<[String: AnyCodable]> {
        try await account.create(
            userId: ID.unique(),
            email: email,
            password: password
        )
    }

    public func onLogin(
        _ email: String,
        _ password: String
    ) async throws -> Session {
        try await account.createEmailPasswordSession(
            email: email,
            password: password
        )
    }

    // -------------------------------------------------------------------------
    func createAccount(
        _ email: String,
        _ password: String
    ) async throws -> User {
        userEmail = "\(Int.random(in: 1..<Int.max))@example.com"

        let user = try await appwriteService.account.create(
            userId: ID.unique(),
            email: email,
            password: password
        )
        userId = user.id

        return User.from(map: user.toMap())
    }

    func getAccount() async throws -> User {
        let user = try await appwriteService.account.get()
        return User.from(map: user.toMap())
    }

    func createSession(
        _ email: String,
        _ password: String
    ) async throws -> Session {
        return try await appwriteService.account.createEmailPasswordSession(
            email: email,
            password: password
        )
    }

    func createAnonymousSession() async throws -> Session {
        return try await appwriteService.account.createAnonymousSession()
    }

    func listSessions() async throws -> [Session] {
        let sessions = try await appwriteService.account.listSessions()
        return sessions.sessions
    }

    func deleteSessions() async throws {
        try await appwriteService.account.deleteSessions()
    }

    func deleteSession() async throws {
        try await appwriteService.account.deleteSession(sessionId: "current")
    }

    func generateJWT() async throws -> Jwt {
        let jwt = try await appwriteService.account.createJWT()
        return jwt
    }

    func socialLogin(provider: String) async throws {
        _ = try await appwriteService.account.createOAuth2Session(
            provider: OAuthProvider(provider) ?? .google)
    }
}
