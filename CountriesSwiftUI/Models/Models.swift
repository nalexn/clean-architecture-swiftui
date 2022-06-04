//
//  Models.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Foundation

struct Country: Codable, Equatable {
    let name: String
    let translations: [String: String?]
    let population: Int
    let flag: URL?
    let alpha3Code: Code
    
    typealias Code = String
    
    enum CodingKeys: String, CodingKey {
        case name
        case translations
        case population
        case flag = "alpha2Code"
        case alpha3Code
    }
    
    init(name: String, translations: [String: String?], population: Int, flag: URL?, alpha3Code: Code) {
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
        if let alpha2orFlagURL = try? values.decode(Code.self, forKey: .flag) {
            let urlString = alpha2orFlagURL.count == 2 ?
            "https://flagcdn.com/w640/\(alpha2orFlagURL.lowercased()).jpg" : alpha2orFlagURL
            flag = URL(string: urlString)
        } else { flag = nil }
        alpha3Code = try values.decode(Code.self, forKey: .alpha3Code)
    }
}

extension Country {
    struct Details: Codable, Equatable {
        let capital: String
        let currencies: [Currency]
        let neighbors: [Country]
    }
}

extension Country.Details {
    struct Intermediate: Codable, Equatable {
        let capital: String
        let currencies: [Country.Currency]
        let borders: [String]
    }
}

extension Country {
    struct Currency: Codable, Equatable {
        let code: String
        let symbol: String?
        let name: String
    }
}

// MARK: - Helpers

extension Country: Identifiable {
    var id: String { alpha3Code }
}

extension Country.Currency: Identifiable {
    var id: String { code }
}

extension Country {
    func name(locale: Locale) -> String {
        let localeId = locale.shortIdentifier
        if let value = translations[localeId], let localizedName = value {
            return localizedName
        }
        return name
    }
}
