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
    let alpha3Code: Code
    
    typealias Code = String
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

extension Country.Currency: Identifiable, Equatable {
    var id: String { code }
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

extension Country.Details {
    static var sampleData: [Country.Details] = {
        let borders = Country.sampleData.map { $0.name }
        return [
            Country.Details(capital: "Sin City", currencies: Country.Currency.sampleData, borders: borders),
            Country.Details(capital: "Los Angeles", currencies: Country.Currency.sampleData, borders: []),
            Country.Details(capital: "New York", currencies: [], borders: []),
            Country.Details(capital: "Moscow", currencies: [], borders: borders)
        ]
    }()
}

extension Country.Currency {
    static let sampleData: [Country.Currency] = [
        Country.Currency(code: "USD", symbol: "$", name: "US Dollar"),
        Country.Currency(code: "EUR", symbol: "€", name: "Euro"),
        Country.Currency(code: "RUB", symbol: "‡", name: "Rouble")
    ]
}

#endif
