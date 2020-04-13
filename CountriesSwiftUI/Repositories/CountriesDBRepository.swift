//
//  CountriesDBRepository.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 13.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import CoreData
import Combine

protocol CountriesDBRepository {
    func hasLoadedCountries() -> Bool
    
    func store(countries: [Country]) -> AnyPublisher<Void, Error>
    func countries(search: String, locale: Locale) -> AnyPublisher<[Country], Error>
    
    func store(countryDetails: Country.Details.Intermediate) -> AnyPublisher<Country.Details?, Error>
    func countryDetails(country: Country) -> AnyPublisher<Country.Details?, Error>
}

struct RealCountriesDBRepository: CountriesDBRepository {
    
    let persistentStore: PersistentStore
    
    func hasLoadedCountries() -> Bool {
        let fetchRequest = CountryMO.justOneRandomCountry()
        return persistentStore.count(fetchRequest) > 0
    }
    
    func store(countries: [Country]) -> AnyPublisher<Void, Error> {
        return persistentStore
            .update { context in
                countries.forEach {
                    $0.store(in: context)
                }
            }
    }
    
    func countries(search: String, locale: Locale) -> AnyPublisher<[Country], Error> {
        let fetchRequest = CountryMO.countries(search: search, locale: locale)
        return persistentStore
            .fetch(fetchRequest)
            .map { managedObjects in
                managedObjects.compactMap { Country(managedObject: $0) }
            }
            .eraseToAnyPublisher()
    }
    
    func store(countryDetails: Country.Details.Intermediate) -> AnyPublisher<Country.Details?, Error> {
        return persistentStore
            .update { context in
                let neighbors = CountryMO
                    .countries(names: countryDetails.borders, locale: .backendDefault)
                let borders = try context.fetch(neighbors)
                let details = countryDetails.store(in: context, borders: borders)
                return details.flatMap { Country.Details(managedObject: $0) }
            }
    }
    
    func countryDetails(country: Country) -> AnyPublisher<Country.Details?, Error> {
        let fetchRequest = CountryDetailsMO.details(country: country)
        return persistentStore
            .fetch(fetchRequest)
            .map { managedObjects in
                managedObjects.first.flatMap { Country.Details(managedObject: $0) }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Fetch Requests

extension CountryMO {
    
    static func justOneRandomCountry() -> NSFetchRequest<CountryMO> {
        let request = newFetchRequest()
        request.predicate = NSPredicate(value: true)
        request.fetchLimit = 1
        return request
    }
    
    static func countries(search: String, locale: Locale) -> NSFetchRequest<CountryMO> {
        let request = newFetchRequest()
        if search.count == 0 {
            request.predicate = NSPredicate(value: true)
        } else {
            let localeId = locale.shortIdentifier
            let nameMatch = NSPredicate(format: "name CONTAINS[cd] %@", search)
            let localizedMatch = NSPredicate(format:
            "(SUBQUERY(nameTranslations,$t,$t.locale == %@ AND $t.name CONTAINS[cd] %@).@count > 0)", localeId, search)
            request.predicate = NSCompoundPredicate(type: .or, subpredicates: [nameMatch, localizedMatch])
        }
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return request
    }
    
    static func countries(names: [String], locale: Locale) -> NSFetchRequest<CountryMO> {
        let request = newFetchRequest()
        request.predicate = NSPredicate(value: true)
        return request
    }
}

extension CountryDetailsMO {
    static func details(country: Country) -> NSFetchRequest<CountryDetailsMO> {
        let request = newFetchRequest()
        request.predicate = NSPredicate(value: true)
        return request
    }
}
