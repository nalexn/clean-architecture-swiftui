//
//  MockedWebRepositories.swift
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

final class MockedCountriesWebRepository: TestWebRepository, Mock, CountriesWebRepository {
    
    enum Action: Equatable {
        case loadCountries
        case loadCountryDetails(Country)
    }
    var actions = MockActions<Action>(expected: [])
    
    var countriesResponse: Result<[Country], Error> = .failure(MockError.valueNotSet)
    var detailsResponse: Result<Country.Details.Intermediate, Error> = .failure(MockError.valueNotSet)
    
    func loadCountries() -> AnyPublisher<[Country], Error> {
        register(.loadCountries)
        return countriesResponse.publish()
    }
    
    func loadCountryDetails(country: Country) -> AnyPublisher<Country.Details.Intermediate, Error> {
        register(.loadCountryDetails(country))
        return detailsResponse.publish()
    }
}

// MARK: - ImageWebRepository

final class MockedImageWebRepository: TestWebRepository, Mock, ImageWebRepository {
    
    enum Action: Equatable {
        case loadImage(URL?)
    }
    var actions = MockActions<Action>(expected: [])
    
    var imageResponse: Result<UIImage, Error> = .failure(MockError.valueNotSet)
    
    func load(imageURL: URL, width: Int) -> AnyPublisher<UIImage, Error> {
        register(.loadImage(imageURL))
        return imageResponse.publish()
    }
}
