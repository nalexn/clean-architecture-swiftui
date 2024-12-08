//
//  CountriesWebRepository.swift
//  CountriesSwiftUI
//
//  Created by Alexey on 7/11/24.
//  Copyright © 2024 Alexey Naumov. All rights reserved.
//

import Foundation

protocol CountriesWebRepository: WebRepository {
    func countries() async throws -> [ApiModel.Country]
    func details(country: DBModel.Country) async throws -> ApiModel.CountryDetails
}

struct RealCountriesWebRepository: CountriesWebRepository {

    let session: URLSession
    let baseURL: String

    init(session: URLSession) {
        self.session = session
        self.baseURL = "https://restcountries.com/v2"
    }

    func countries() async throws -> [ApiModel.Country] {
        return try await call(endpoint: API.allCountries)
    }

    func details(country: DBModel.Country) async throws -> ApiModel.CountryDetails {
        let response: [ApiModel.CountryDetails] = try await call(endpoint: API.countryDetails(countryName: country.name))
        guard let details = response.first else {
            throw APIError.unexpectedResponse
        }
        return details
    }
}

// MARK: - Endpoints

extension RealCountriesWebRepository {
    enum API {
        case allCountries
        case countryDetails(countryName: String)
    }
}

extension RealCountriesWebRepository.API: APICall {
    var path: String {
        switch self {
        case .allCountries:
            return "/all"
        case let .countryDetails(countryName):
            let encodedName = countryName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            return "/name/\(encodedName ?? countryName)"
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
