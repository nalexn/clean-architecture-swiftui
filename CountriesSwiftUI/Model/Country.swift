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
    struct Details {
        let capital: String
        let currencies: [Currency]
        let neighbors: [Country]
    }
}

extension Country.Details {
    struct Intermediate: Codable {
        let capital: String
        let currencies: [Country.Currency]
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

extension Country.Details.Intermediate {
    func substituteNeighbors(countries: [Country]) -> Country.Details {
        let countries = self.borders.compactMap({ code in
            return countries.first(where: { $0.alpha3Code == code })
        })
        return Country.Details(capital: capital, currencies: currencies, neighbors: countries)
    }
}

#if DEBUG

extension Country {
    static let sampleData: [Country] = [
        Country(name: "United States", population: 125000000, flag: URL(string: "https://restcountries.eu/data/usa.svg"), alpha3Code: "USA"),
        Country(name: "Georgia", population: 2340000, flag: nil, alpha3Code: "GEO"),
        Country(name: "Canada", population: 57600000, flag: nil, alpha3Code: "CAN")
    ]
}

extension Country.Details {
    static var sampleData: [Country.Details] = {
        let neighbors = Country.sampleData
        return [
            Country.Details(capital: "Sin City", currencies: Country.Currency.sampleData, neighbors: neighbors),
            Country.Details(capital: "Los Angeles", currencies: Country.Currency.sampleData, neighbors: []),
            Country.Details(capital: "New York", currencies: [], neighbors: []),
            Country.Details(capital: "Moscow", currencies: [], neighbors: neighbors)
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
