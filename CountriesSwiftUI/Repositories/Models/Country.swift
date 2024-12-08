//
//  Country.swift
//  CountriesSwiftUI
//
//  Created by Alexey on 7/11/24.
//  Copyright © 2024 Alexey Naumov. All rights reserved.
//

import Foundation
import SwiftData

// MARK: - Database Model

extension DBModel {

    @Model final class Country {

        var name: String
        var translations: [String: String?]
        var population: Int
        var flag: URL?
        @Attribute(.unique) var alpha3Code: String
        @Relationship(inverse: \CountryDetails.neighbors) var neighbors: [CountryDetails] = []

        init(name: String, translations: [String: String?], population: Int, flag: URL? = nil, alpha3Code: String) {
            self.name = name
            self.translations = translations
            self.population = population
            self.flag = flag
            self.alpha3Code = alpha3Code
        }

        func name(locale: Locale) -> String {
            let localeId = locale.shortIdentifier
            if let value = translations[localeId], let localizedName = value {
                return localizedName
            }
            return name
        }
    }
}

// MARK: - Web API Model

extension ApiModel {

    struct Country: Codable, Equatable {

        let name: String
        let translations: [String: String?]
        let population: Int
        let flag: URL?
        let alpha3Code: String

        enum CodingKeys: String, CodingKey {
            case name
            case translations
            case population
            case flag = "alpha2Code"
            case alpha3Code
        }

        init(name: String, translations: [String: String?], population: Int, flag: URL?, alpha3Code: String) {
            self.name = name
            self.translations = translations
            self.population = population
            self.flag = flag
            self.alpha3Code = alpha3Code
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            name = try values.decode(String.self, forKey: .name)
            translations = try values.decode([String: String?].self, forKey: .translations)
            population = try values.decode(Int.self, forKey: .population)
            if let alpha2orFlagURL = try? values.decode(String.self, forKey: .flag) {
                let urlString = alpha2orFlagURL.count == 2 ?
                "https://flagcdn.com/w640/\(alpha2orFlagURL.lowercased()).jpg" : alpha2orFlagURL
                flag = URL(string: urlString)
            } else { flag = nil }
            alpha3Code = try values.decode(String.self, forKey: .alpha3Code)
        }
    }
}
