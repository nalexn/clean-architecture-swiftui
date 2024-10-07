//
//  UserManagementService.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-05.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

import Appwrite
import Foundation

protocol UserManagementServiceProtocol {
    func createUser(_ user: CustomUserAttributes) async throws -> UserDocument
    func getUser(id: String) async throws -> UserDocument
    func updateUser(id: String, updatedUser: CustomUserAttributes) async throws -> UserDocument
    func deleteUser(id: String) async throws
    func listUsers(queries: [String]?) async throws -> [UserDocument]
}

class UserManagementService: UserManagementServiceProtocol {
    private let appwriteService: AppwriteService

    init(appwriteService: AppwriteService) {
        self.appwriteService = appwriteService
    }

    // Create
    func createUser(_ user: CustomUserAttributes) async throws -> UserDocument {
        let document = try await appwriteService.databases.createDocument(
            databaseId: appwriteService.databaseId,
            collectionId: appwriteService.collectionId,
            documentId: ID.unique(),
            data: user
        )
        return UserDocument.from(map: document.toMap())
    }

    // Read
    func getUser(id: String) async throws -> UserDocument {
        let document = try await appwriteService.databases.getDocument(
            databaseId: appwriteService.databaseId,
            collectionId: appwriteService.collectionId,
            documentId: id
        )
        return UserDocument.from(map: document.toMap())
    }

    // Update
    func updateUser(id: String, updatedUser: CustomUserAttributes) async throws -> UserDocument {
        let document = try await appwriteService.databases.updateDocument(
            databaseId: appwriteService.databaseId,
            collectionId: appwriteService.collectionId,
            documentId: id,
            data: updatedUser
        )
        return UserDocument.from(map: document.toMap())
    }

    // Delete
    func deleteUser(id: String) async throws {
        try await appwriteService.databases.deleteDocument(
            databaseId: appwriteService.databaseId,
            collectionId: appwriteService.collectionId,
            documentId: id
        )
    }

    // List Users
    func listUsers(queries: [String]? = nil) async throws -> [UserDocument] {
        let documents = try await appwriteService.databases.listDocuments(
            databaseId: appwriteService.databaseId,
            collectionId: appwriteService.collectionId,
            queries: queries
        )
        return documents.documents.map { UserDocument.from(map: $0.toMap()) }
    }
}
