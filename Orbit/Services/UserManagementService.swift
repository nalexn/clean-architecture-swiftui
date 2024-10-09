//
//  UserManagementService.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-05.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

import Appwrite
import Foundation
import JSONCodable

protocol UserManagementServiceProtocol {
    func createUser(_ user: UserModel) async throws -> UserDocument
    func getUser(_ accountId: String) async throws -> UserDocument?
    func getCurrentUser() async throws -> UserModel?
    func updateUser(accountId: String, updatedUser: UserModel) async throws
        -> UserDocument?
    func deleteUser(_ accountId: String) async throws
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
    func getUser(_ accountId: String) async throws -> UserDocument? {
        print("acctID: \(accountId)")
        let query = Query.equal(
            "accountId",
            value: accountId
        )  // Query by accountId
        let response = try await appwriteService.databases.listDocuments<
            UserModel
        >(
            databaseId: appwriteService.databaseId,
            collectionId: appwriteService.collectionId,
            queries: [query],
            nestedType: UserModel.self

        )
        // Check if any document was found
        if let document = response.documents.first {
            return document
        } else {
            throw NSError(domain: "User not found", code: 404, userInfo: nil)
        }
    }

    func getCurrentUser() async throws -> UserModel? {
        let document = try await appwriteService.account.get()
        let userAccountId = document.id
        return try await getUser(userAccountId)?.data
    }

    // Update the user based on accountId (not documentId)
    func updateUser(accountId: String, updatedUser: UserModel) async throws
        -> UserDocument?
    {
        // First, fetch the document based on accountId
        guard let userDocument = try await getUser(accountId) else {
            print("can't update user")
            return nil
        }

        // Now, use the documentId of the retrieved user document to update it
        let documentId = userDocument.id  // Get the actual documentId from the user document

        // Perform the update using the documentId
        let updatedDocument = try await appwriteService.databases
            .updateDocument<UserModel>(
                databaseId: appwriteService.databaseId,
                collectionId: appwriteService.collectionId,
                documentId: documentId,  // Use the documentId instead of accountId
                data: updatedUser,
                permissions: nil,
                nestedType: UserModel.self
            )

        return updatedDocument
    }

    // Delete the user based on accountId (not documentId)
    func deleteUser(_ accountId: String) async throws {
        // First, fetch the document based on accountId
        guard let userDocument = try await getUser(accountId) else {
            throw NSError(domain: "User not found", code: 404, userInfo: nil)
        }

        // Now, use the documentId of the retrieved user document to delete it
        let documentId = userDocument.id  // Get the actual documentId from the user document

        // Perform the delete operation using the documentId
        try await appwriteService.databases.deleteDocument(
            databaseId: appwriteService.databaseId,
            collectionId: appwriteService.collectionId,
            documentId: documentId  // Use the documentId instead of accountId
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
