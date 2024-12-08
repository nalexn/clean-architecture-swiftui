//
//  CountryCurrency.swift
//  CountriesSwiftUI
//
//  Created by Alexey on 8/11/24.
//  Copyright © 2024 Alexey Naumov. All rights reserved.
//

import SwiftData

// MARK: - Database Model

extension DBModel {
    @Model final class Currency {
        @Relationship(inverse: \CountryDetails.currencies) var countries: [CountryDetails] = []
        @Attribute(.unique) var code: String
        var symbol: String?
        var name: String

        init(code: String, symbol: String?, name: String) {
            self.code = code
            self.symbol = symbol
            self.name = name
        }
    }
}

// MARK: - Web API Model

extension ApiModel {
    struct Currency: Codable, Equatable {
        let code: String
        let symbol: String?
        let name: String
    }
}
