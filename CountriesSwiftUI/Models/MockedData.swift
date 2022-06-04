//
//  MockedModel.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 27.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Foundation

#if DEBUG

extension Country {
    static let mockedData: [Country] = [
        Country(name: "United States", translations: [:], population: 125000000,
                flag: URL(string: "https://flagcdn.com/w640/us.jpg"), alpha3Code: "USA"),
        Country(name: "Georgia", translations: [:], population: 2340000, flag: nil, alpha3Code: "GEO"),
        Country(name: "Canada", translations: [:], population: 57600000, flag: nil, alpha3Code: "CAN")
    ]
}

extension Country.Details {
    static var mockedData: [Country.Details] = {
        let neighbors = Country.mockedData
        return [
            Country.Details(capital: "Sin City", currencies: Country.Currency.mockedData, neighbors: neighbors),
            Country.Details(capital: "Los Angeles", currencies: Country.Currency.mockedData, neighbors: []),
            Country.Details(capital: "New York", currencies: [], neighbors: []),
            Country.Details(capital: "Moscow", currencies: [], neighbors: neighbors)
        ]
    }()
}

extension Country.Currency {
    static let mockedData: [Country.Currency] = [
        Country.Currency(code: "USD", symbol: "$", name: "US Dollar"),
        Country.Currency(code: "EUR", symbol: "€", name: "Euro"),
        Country.Currency(code: "RUB", symbol: "‡", name: "Rouble")
    ]
}

#endif
