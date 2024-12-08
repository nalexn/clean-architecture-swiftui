//
//  AppSchema.swift
//  CountriesSwiftUI
//
//  Created by Alexey on 7/11/24.
//  Copyright © 2024 Alexey Naumov. All rights reserved.
//

import SwiftData

enum DBModel { }

extension Schema {
    private static var actualVersion: Schema.Version = Version(1, 0, 0)

    static var appSchema: Schema {
        Schema([
            DBModel.Country.self,
            DBModel.CountryDetails.self,
            DBModel.Currency.self,
        ], version: actualVersion)
    }
}
