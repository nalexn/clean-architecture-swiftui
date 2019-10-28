//
//  CountriesService.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

protocol CountriesServiceProtocol {
    func loadCountries()
    func load(countryDetails: Binding<Loadable<Country.Details>>, country: Country)
}

struct RealCountriesService: CountriesServiceProtocol, WebService {
    
    let session: URLSession
    let baseURL: String
    let appState: AppState
    let bgQueue = DispatchQueue(label: "bg_parse_queue")
    
    init(session: URLSession, baseURL: String, appState: AppState) {
        self.session = session
        self.baseURL = baseURL
        self.appState = appState
    }
    
    typealias API = CountriesService.APICall

    func loadCountries() {
        appState.userData.countries = .isLoading(last: appState.userData.countries.value)
        weak var weakAppState = appState
        let request: AnyPublisher<[Country], Error> = call(endpoint: API.allCountries)
        _ = request
            .map { Loadable<[Country]>.loaded($0) }
            .catch { Just<Loadable<[Country]>>(.failed($0)) }
            .sink { weakAppState?.userData.countries = $0 }
    }

    func load(countryDetails: Binding<Loadable<Country.Details>>, country: Country) {
        countryDetails.wrappedValue = .isLoading(last: countryDetails.wrappedValue.value)
        let request: AnyPublisher<[Country.Details.Intermediate], Error> = call(endpoint: API.countryDetails(country))
        let countriesArray = appState.$userData
            .map { $0.countries.value ?? [] }
        _ = request
            .map { array -> Loadable<Country.Details.Intermediate> in
                if let details = array.first {
                    return .loaded(details)
                } else {
                    return .failed(APIError.unexpectedResponse)
                }
            }
            .catch { Just<Loadable<Country.Details.Intermediate>>(.failed($0)) }
            .combineLatest(countriesArray)
            .receive(on: bgQueue)
            .map { (detailsIntermediate, countries) -> Loadable<Country.Details> in
                detailsIntermediate.map {
                    $0.substituteNeighbors(countries: countries)
                }
            }
            .receive(on: RunLoop.main)
            .sink { countryDetails.wrappedValue = $0 }
    }
}

// MARK: - Endpoints

struct CountriesService { }

extension CountriesService {
    enum APICall {
        case allCountries
        case countryDetails(Country)
    }
}

extension CountriesService.APICall: APICall {
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

struct FakeCountriesService: CountriesServiceProtocol {
    
    func loadCountries() {
    }
    
    func load(countryDetails: Binding<Loadable<Country.Details>>, country: Country) {
    }
}
