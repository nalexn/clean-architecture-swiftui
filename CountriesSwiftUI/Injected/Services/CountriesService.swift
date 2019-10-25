//
//  CountriesService.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Combine
import Foundation

protocol CountriesServiceProtocol {
    func loadCountries() -> Cancellable
    func load(countryDetails: Resource<Country.Details>, country: Country) -> Cancellable
}

struct RealCountriesService: CountriesServiceProtocol, Service {
    
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

    func loadCountries() -> Cancellable {
        let countries = appState.countries
        countries.send(.isLoading(last: countries.value.value))
        let request: AnyPublisher<[Country], Error> = call(endpoint: API.allCountries)
        return request
            .map { Loadable<[Country]>.loaded($0) }
            .catch { Just<Loadable<[Country]>>(.failed($0)) }
            .sink { countries.send($0) }
    }

    func load(countryDetails: Resource<Country.Details>, country: Country) -> Cancellable {
        countryDetails.send(.isLoading(last: countryDetails.value.value))
        let request: AnyPublisher<[Country.Details], Error> = call(endpoint: API.countryDetails(country))
        let countriesArray = appState.countries.map({ $0.value ?? [] }).removeDuplicates()
        return request
            .map { array -> Loadable<Country.Details> in
                if let details = array.first {
                    return .loaded(details)
                } else {
                    return .failed(APIError.unexpectedResponse)
                }
            }
            .catch { Just<Loadable<Country.Details>>(.failed($0)) }
            .combineLatest(countriesArray)
            .receive(on: bgQueue)
            .map { (loadableDetails, countries) -> Loadable<Country.Details> in
                return loadableDetails.updatedValue {
                    return $0.substitutedCountriesAtBorders(countries: countries)
                }
            }
            .receive(on: RunLoop.main)
            .sink { countryDetails.send($0) }
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
            return "/name/\(country.name)"
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

#if DEBUG
struct FakeCountriesService: CountriesServiceProtocol {
    
    func loadCountries() -> Cancellable {
        return AnyCancellable.init { }
    }
    
    func load(countryDetails: Resource<Country.Details>, country: Country) -> Cancellable {
        return AnyCancellable.init { }
    }
}
#endif
