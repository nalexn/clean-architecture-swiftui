//
//  MockedCountriesWebRepository.swift
//  UnitTests
//
//  Created by Alexey Naumov on 31.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import Combine
@testable import CountriesSwiftUI

class TestWebRepository: WebRepository {
    let session: URLSession = .mockedResponsesOnly
    let baseURL = "https://test.com"
    let bgQueue = DispatchQueue(label: "test")
}

// MARK: - CountriesWebRepository

class MockedCountriesWebRepository: TestWebRepository, CountriesWebRepository {
    
    var countriesResponse: Result<[Country], Error> = .failure(MockError.valueNotSet)
    var detailsResponse: Result<Country.Details.Intermediate, Error> = .failure(MockError.valueNotSet)
    
    func loadCountries() -> AnyPublisher<[Country], Error> {
        return countriesResponse.publish()
    }
    
    func loadCountryDetails(country: Country) -> AnyPublisher<Country.Details.Intermediate, Error> {
        return detailsResponse.publish()
    }
}
