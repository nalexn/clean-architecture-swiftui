//
//  CountriesWebRepository.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 29.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Combine
import Foundation

protocol CountriesWebRepository: WebRepository {
    func loadCountries() -> AnyPublisher<[Country], Error>
    func loadCountryDetails(country: Country) -> AnyPublisher<Country.Details.Intermediate, Error>
}

struct RealCountriesWebRepository: CountriesWebRepository {
    
    let session: URLSession
    let baseURL: String
    let bgQueue = DispatchQueue(label: "bg_parse_queue")
    
    init(session: URLSession, baseURL: String) {
        self.session = session
        self.baseURL = baseURL
    }
    
    func loadCountries() -> AnyPublisher<[Country], Error> {
        return call(endpoint: API.allCountries)
    }

    func loadCountryDetails(country: Country) -> AnyPublisher<Country.Details.Intermediate, Error> {
        let request: AnyPublisher<[Country.Details.Intermediate], Error> = call(endpoint: API.countryDetails(country))
        return request
            .tryMap { array -> Country.Details.Intermediate in
                guard let details = array.first
                    else { throw APIError.unexpectedResponse }
                return details
            }
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
