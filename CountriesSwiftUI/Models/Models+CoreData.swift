//
//  Models+CoreData.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 12.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import Foundation
import CoreData

extension CountryMO: ManagedEntity { }
extension NameTranslationMO: ManagedEntity { }
extension CountryDetailsMO: ManagedEntity { }
extension CurrencyMO: ManagedEntity { }

extension Locale {
    static var backendDefault: Locale {
        return Locale(identifier: "en")
    }
    
    var shortIdentifier: String {
        return String(identifier.prefix(2))
    }
}

extension Country.Details {
    
    init?(managedObject: CountryDetailsMO) {
        guard let capital = managedObject.capital
            else { return nil }
        
        let currencies = (managedObject.currencies ?? NSSet())
            .toArray(of: CurrencyMO.self)
            .compactMap { Country.Currency(managedObject: $0) }
        
        let borders = (managedObject.borders ?? NSSet())
            .toArray(of: CountryMO.self)
            .compactMap { Country(managedObject: $0) }
        
        self.init(capital: capital, currencies: currencies, neighbors: borders)
    }
}

extension Country.Details.Intermediate {
    
    @discardableResult
    func store(in context: NSManagedObjectContext, borders: [CountryMO]) -> CountryDetailsMO? {
        guard let details = CountryDetailsMO.insertNew(in: context)
            else { return nil }
        details.capital = capital
        let storedCurrencies = currencies.compactMap { $0.store(in: context) }
        details.currencies = NSSet(array: storedCurrencies)
        details.borders = NSSet(array: borders)
        return details
    }
}

extension Country.Currency {
    
    init?(managedObject: CurrencyMO) {
        guard let code = managedObject.code,
            let name = managedObject.name
            else { return nil }
        self.init(code: code, symbol: managedObject.symbol, name: name)
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> CurrencyMO? {
        guard let currency = CurrencyMO.insertNew(in: context)
            else { return nil }
        currency.code = code
        currency.name = name
        currency.symbol = symbol
        return currency
    }
}

extension Country {
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> CountryMO? {
        guard let country = CountryMO.insertNew(in: context)
            else { return nil }
        country.name = name
        country.alpha3code = alpha3Code
        country.population = Int32(population)
        country.flagURL = flag?.absoluteString
        let translations = self.translations
            .compactMap { (locale, name) -> NameTranslationMO? in
                guard let name = name,
                    let translation = NameTranslationMO.insertNew(in: context)
                else { return nil }
                translation.name = name
                translation.locale = locale
                return translation
            }
        country.nameTranslations = NSSet(array: translations)
        return country
    }
    
    init?(managedObject: CountryMO) {
        guard let nameTranslations = managedObject.nameTranslations
            else { return nil }
        let translations: [String: String?] = nameTranslations
            .toArray(of: NameTranslationMO.self)
            .reduce([:], { (dict, record) -> [String: String?] in
                guard let locale = record.locale, let name = record.name
                    else { return dict }
                var dict = dict
                dict[locale] = name
                return dict
            })
        guard let name = managedObject.name,
            let alpha3code = managedObject.alpha3code
            else { return nil }
        
        self.init(name: name, translations: translations,
                  population: Int(managedObject.population),
                  flag: managedObject.flagURL.flatMap { URL(string: $0) },
                  alpha3Code: alpha3code)
    }
}
