//
//  CountriesWebRepository.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 29.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Combine
import Foundation

protocol CountriesWebRepository {
    func loadCountries() -> AnyPublisher<[Country], Error>
    func loadCountryDetails(country: Country) -> AnyPublisher<Country.Details, Error>
}

struct RealCountriesWebRepository: CountriesWebRepository, WebRepository {
    
    let session: URLSession
    let baseURL: String
    let appState: AppState
    let bgQueue = DispatchQueue(label: "bg_parse_queue")
    
    init(session: URLSession, baseURL: String, appState: AppState) {
        self.session = session
        self.baseURL = baseURL
        self.appState = appState
    }
    
    func loadCountries() -> AnyPublisher<[Country], Error> {
        return call(endpoint: API.allCountries)
    }

    func loadCountryDetails(country: Country) -> AnyPublisher<Country.Details, Error> {
        let request: AnyPublisher<[Country.Details.Intermediate], Error> = call(endpoint: API.countryDetails(country))
        let countriesArray = appState.$userData
            .tryMap { userData -> [Country] in
                if let error = userData.countries.error {
                    throw error
                }
                return userData.countries.value ?? []
            }
        return request
            .tryMap { array -> Country.Details.Intermediate in
                guard let details = array.first
                    else { throw APIError.unexpectedResponse }
                return details
            }
            .combineLatest(countriesArray)
            .receive(on: bgQueue)
            .map { (intermediate, countries) -> Country.Details in
                intermediate.substituteNeighbors(countries: countries)
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Endpoints

extension RealCountriesWebRepository {
    enum API {
        case allCountries
        case countryDetails(Country)
    }
}

extension RealCountriesWebRepository.API: APICall {
    var path: String {
        switch self {
        case .allCountries:
            return "/all"
        case let .countryDetails(country):
            let encodedName = country.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            return "/name/\(encodedName ?? country.name)"
        }
    }
    var method: String {
        switch self {
        case .allCountries, .countryDetails:
            return "GET"
        }
    }
    var headers: [String: String]? {
        return ["Accept": "application/json"]
    }
    func body() throws -> Data? {
        return nil
    }
}
