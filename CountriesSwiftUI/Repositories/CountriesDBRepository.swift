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
    func hasLoadedCountries() -> AnyPublisher<Bool, Error>
    
    func store(countries: [Country]) -> AnyPublisher<Void, Error>
    func countries(search: String, locale: Locale) -> AnyPublisher<LazyList<Country>, Error>
    
    func store(countryDetails: Country.Details.Intermediate,
               for country: Country) -> AnyPublisher<Country.Details?, Error>
    func countryDetails(country: Country) -> AnyPublisher<Country.Details?, Error>
}

struct RealCountriesDBRepository: CountriesDBRepository {
    
    let persistentStore: PersistentStore
    
    func hasLoadedCountries() -> AnyPublisher<Bool, Error> {
        let fetchRequest = CountryMO.justOneCountry()
        return persistentStore
            .count(fetchRequest)
            .map { $0 > 0 }
            .eraseToAnyPublisher()
    }
    
    func store(countries: [Country]) -> AnyPublisher<Void, Error> {
        return persistentStore
            .update { context in
                countries.forEach {
                    $0.store(in: context)
                }
            }
    }
    
    func countries(search: String, locale: Locale) -> AnyPublisher<LazyList<Country>, Error> {
        let fetchRequest = CountryMO.countries(search: search, locale: locale)
        return persistentStore
            .fetch(fetchRequest) {
                Country(managedObject: $0)
            }
            .eraseToAnyPublisher()
    }
    
    func store(countryDetails: Country.Details.Intermediate,
               for country: Country) -> AnyPublisher<Country.Details?, Error> {
        return persistentStore
            .update { context in
                let parentRequest = CountryMO.countries(alpha3codes: [country.alpha3Code])
                guard let parent = try context.fetch(parentRequest).first
                    else { return nil }
                let neighbors = CountryMO.countries(alpha3codes: countryDetails.borders)
                let borders = try context.fetch(neighbors)
                let details = countryDetails.store(in: context, country: parent, borders: borders)
                return details.flatMap { Country.Details(managedObject: $0) }
            }
    }
    
    func countryDetails(country: Country) -> AnyPublisher<Country.Details?, Error> {
        let fetchRequest = CountryDetailsMO.details(country: country)
        return persistentStore
            .fetch(fetchRequest) {
                Country.Details(managedObject: $0)
            }
            .map { $0.first }
            .eraseToAnyPublisher()
    }
}

// MARK: - Fetch Requests

extension CountryMO {
    
    static func justOneCountry() -> NSFetchRequest<CountryMO> {
        let request = newFetchRequest()
        request.predicate = NSPredicate(format: "alpha3code == %@", "USA")
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
        request.fetchBatchSize = 10
        return request
    }
    
    static func countries(alpha3codes: [String]) -> NSFetchRequest<CountryMO> {
        let request = newFetchRequest()
        request.predicate = NSPredicate(format: "alpha3code in %@", alpha3codes)
        request.fetchLimit = alpha3codes.count
        return request
    }
}

extension CountryDetailsMO {
    static func details(country: Country) -> NSFetchRequest<CountryDetailsMO> {
        let request = newFetchRequest()
        request.predicate = NSPredicate(format: "country.alpha3code == %@", country.alpha3Code)
        request.fetchLimit = 1
        return request
    }
}
