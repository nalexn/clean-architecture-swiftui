//
//  Country.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Foundation

struct Country: Codable {
    let name: String
    let population: Int
    let flag: URL?
    let alpha3Code: String
}

extension Country {
    struct Details: Codable {
        let capital: String
        let currencies: [Currency]
        let borders: [String]
    }
}

extension Country {
    struct Currency: Codable {
        let code: String
        let symbol: String?
        let name: String
    }
}

// MARK: - Helpers

extension Country: Identifiable, Equatable {
    var id: String { alpha3Code }
}

extension Country.Details {
    func substitutedCountriesAtBorders(countries: [Country]) -> Country.Details {
        let borders = self.borders.compactMap({ code in
            return countries.first(where: { $0.alpha3Code == code })?.name
        })
        return Country.Details(capital: capital, currencies: currencies, borders: borders)
    }
}

#if DEBUG

extension Country {
    static let sampleData: [Country] = [
        Country(name: "United States", population: 125000000, flag: nil, alpha3Code: "USA"),
        Country(name: "Georgia", population: 2340000, flag: nil, alpha3Code: "GEO"),
        Country(name: "Canada", population: 57600000, flag: nil, alpha3Code: "CAN")
    ]
}

#endif
