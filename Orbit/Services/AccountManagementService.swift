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
import AppwriteModels
import Foundation
import JSONCodable

protocol AccountManagementServiceProtocol {
    func createAccount(_ email: String, _ password: String, _ name: String)
        async throws
        -> AppwriteModels.User<[String: AnyCodable]>
    func getAccount() async throws -> User<[String: AnyCodable]>
    func createSession(_ email: String, _ password: String) async throws
        -> Session
    func createAnonymousSession() async throws -> Session
    func listSessions() async throws -> [Session]
    func deleteSessions() async throws
    func deleteSession() async throws
    func generateJWT() async throws -> Jwt
    func socialLogin(provider: String) async throws
}

class AccountManagementService: AccountManagementServiceProtocol {
    private let account: Account = AppwriteService.shared.account

    //    init(appwriteServiceAccount: Account) {
    //        self.account = appwriteServiceAccount
    //    }

    // -------------------------------------------------------------------------
    func createAccount(
        _ email: String,
        _ password: String,
        _ name: String
    ) async throws -> AppwriteModels.User<[String: AnyCodable]> {
        let user = try await account.create(
            userId: ID.unique(),
            email: email,
            password: password,
            name: name
        )
        print("userServiceCreated: \(user.id)")
        return user
        //        return User.from(map: user.toMap())
    }

    func getAccount() async throws -> User<[String: AnyCodable]> {
        let user = try await account.get()
        return user
    }

    func createSession(
        _ email: String,
        _ password: String
    ) async throws -> Session {
        return try await account.createEmailPasswordSession(
            email: email,
            password: password
        )
    }

    func createAnonymousSession() async throws -> Session {
        return try await account.createAnonymousSession()
    }

    func listSessions() async throws -> [Session] {
        let sessions = try await account.listSessions()
        return sessions.sessions
    }

    func deleteSessions() async throws {
        try await account.deleteSessions()
    }

    func deleteSession() async throws {
        try await account.deleteSession(sessionId: "current")
    }

    func generateJWT() async throws -> Jwt {
        let jwt = try await account.createJWT()
        return jwt
    }

    func socialLogin(provider: String) async throws {
        _ = try await account.createOAuth2Session(
            provider: .google)
    }
}
