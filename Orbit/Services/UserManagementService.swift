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
    func createUser(_ user: UserModel) async throws -> UserDocument
    func getUser(id: String) async throws -> UserDocument
    func updateUser(id: String, updatedUser: UserModel) async throws
        -> UserDocument
    func deleteUser(id: String) async throws
    func listUsers(queries: [String]?) async throws -> [UserDocument]
}

class UserManagementService: UserManagementServiceProtocol {
    private let appwriteService: AppwriteService = AppwriteService.shared

    //    init(appwriteService: AppwriteService) {
    //        self.appwriteService = appwriteService
    //    }

    // Create
    func createUser(_ user: UserModel) async throws -> UserDocument {

        print(appwriteService.collectionId, appwriteService.databaseId)

        let document = try await appwriteService.databases.createDocument<
            UserModel
        >(
            databaseId: appwriteService.databaseId,
            collectionId: appwriteService.collectionId,
            documentId: ID.unique(),
            data: user.toJson(),
            permissions: nil,  // [Appwrite.Permission.write(Role.user(user.accountId))],
            nestedType: UserModel.self
        )
        print(document)
        return document
        //        return UserDocument.from(map: document.toMap())
    }

    // Read
    func getUser(id: String) async throws -> UserDocument {
        let document = try await appwriteService.databases.getDocument<
            UserModel
        >(
            databaseId: appwriteService.databaseId,
            collectionId: appwriteService.collectionId,
            documentId: id,
            queries: nil,
            nestedType: UserModel.self

        )
        return document
    }

    // Update
    func updateUser(id: String, updatedUser: UserModel) async throws
        -> UserDocument
    {
        let document = try await appwriteService.databases.updateDocument<
            UserModel
        >(
            databaseId: appwriteService.databaseId,
            collectionId: appwriteService.collectionId,
            documentId: id,
            data: updatedUser,
            permissions: nil,
            nestedType: UserModel.self
        )
        return document
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
        let documents = try await appwriteService.databases.listDocuments<
            UserModel
        >(
            databaseId: appwriteService.databaseId,
            collectionId: appwriteService.collectionId,
            queries: queries,
            nestedType: UserModel.self

        )
        return documents.documents
    }
}
