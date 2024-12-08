//
//  MockedModel.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 27.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Foundation

#if DEBUG

@MainActor
extension ApiModel.Country {
    static let mockedData: [ApiModel.Country] = [
        ApiModel.Country(name: "United States", translations: [:], population: 125000000,
                flag: URL(string: "https://flagcdn.com/w640/us.jpg"), alpha3Code: "USA"),
        ApiModel.Country(name: "Georgia", translations: [:], population: 2340000, flag: nil, alpha3Code: "GEO"),
        ApiModel.Country(name: "Canada", translations: [:], population: 57600000, flag: nil, alpha3Code: "CAN")
    ]
}

@MainActor
extension ApiModel.CountryDetails {
    static var mockedData: [ApiModel.CountryDetails] = {
        let neighbors = ApiModel.Country.mockedData
        return [
            ApiModel.CountryDetails(capital: "Sin City", currencies: ApiModel.Currency.mockedData, borders: ["abc"]),
            ApiModel.CountryDetails(capital: "Los Angeles", currencies: ApiModel.Currency.mockedData, borders: []),
            ApiModel.CountryDetails(capital: "New York", currencies: [], borders: []),
            ApiModel.CountryDetails(capital: "Moscow", currencies: [], borders: ["xyz"])
        ]
    }()
}

@MainActor
extension ApiModel.Currency {
    static let mockedData: [ApiModel.Currency] = [
        ApiModel.Currency(code: "USD", symbol: "$", name: "US Dollar"),
        ApiModel.Currency(code: "EUR", symbol: "€", name: "Euro"),
        ApiModel.Currency(code: "RUB", symbol: "‡", name: "Rouble")
    ]
}

#endif
