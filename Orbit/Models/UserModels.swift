//
//  UserModels.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-05.
//  Copyright © 2024 CPSC 575. All rights reserved.
//

import Appwrite
import CoreLocation
import Foundation

struct UserModel: Codable, Identifiable {
    let accountId: String
    var id: String {
        return accountId
    }
    var name: String
    var interests: [String]?
    //    let bio: String?
    //    let location: Location?
    //    let friends: [String]?
    //    let followers: [String]?
    //    let following: [String]?
    //    let profilePictureId: String?  // Reference to the File ID
    //    let settings: Settings?
}

struct Location: Codable {
    let type: String
    let coordinates: [Double]

    var coordinate: CLLocationCoordinate2D? {
        guard type == "Point", coordinates.count == 2 else { return nil }
        return CLLocationCoordinate2D(
            latitude: coordinates[1], longitude: coordinates[0])
    }
}

struct Settings: Codable {
    let isPrivateProfile: Bool
    let notificationsEnabled: Bool
}

typealias UserDocument = AppwriteModels.Document<UserModel>
