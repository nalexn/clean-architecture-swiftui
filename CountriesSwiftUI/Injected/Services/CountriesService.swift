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
    var countries: Resource<[Country]> { get }
    func loadCountriesList()
    func countryDetails(country: Country) -> AnyPublisher<Loadable<Country.Details>, Never>
}

class RealCountriesService: CountriesServiceProtocol, Service {
    
    private var runningCountriesRequest: Cancellable?
    let session: URLSession
    let baseURL: String
    let bgQueue = DispatchQueue(label: "bg_parse_queue")

    let countries = Resource<[Country]>(.notRequested)
    
    init(session: URLSession, baseURL: String) {
        self.session = session
        self.baseURL = baseURL
    }
    
    typealias API = CountriesService.APICall

    func loadCountriesList() {
        runningCountriesRequest?.cancel()
        countries.send(.isLoading(last: countries.value.value))
        let request: AnyPublisher<[Country], Error> = call(endpoint: API.allCountries)
        runningCountriesRequest = request
            .map { Loadable<[Country]>.loaded($0) }
            .catch { Just<Loadable<[Country]>>(.failed($0)) }
            .sink { [weak self] countries in
                self?.countries.send(countries)
                self?.runningCountriesRequest = nil
            }
    }

    func countryDetails(country: Country) -> AnyPublisher<Loadable<Country.Details>, Never> {
        
        let request: AnyPublisher<[Country.Details], Error> = call(endpoint: API.countryDetails(country))
        let countriesArray = countries.map({ $0.value ?? [] }).removeDuplicates()
        return request
            .map { array -> Loadable<Country.Details> in
                if let details = array.first {
                    return .loaded(details)
                } else {
                    return .failed(APICallError.unexpectedResponse)
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
            .eraseToAnyPublisher()
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
struct MockedCountriesService: CountriesServiceProtocol {
    
    let countries: Resource<[Country]>
    
    func loadCountriesList() {
        
    }
    
    func countryDetails(country: Country) -> AnyPublisher<Loadable<Country.Details>, Never> {
        return Just<Loadable<Country.Details>>(.notRequested).eraseToAnyPublisher()
    }
    
    init(countries: Loadable<[Country]>) {
        self.countries = CurrentValueSubject(countries)
    }
}
#endif
