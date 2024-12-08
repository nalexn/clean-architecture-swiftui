//
//  MockedWebRepositories.swift
//  UnitTests
//
//  Created by Alexey Naumov on 31.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Foundation
import UIKit.UIImage
@testable import CountriesSwiftUI

class TestWebRepository: WebRepository {
    let session: URLSession = .mockedResponsesOnly
    let baseURL = "https://test.com"
}

// MARK: - CountriesWebRepository

final class MockedCountriesWebRepository: TestWebRepository, Mock, CountriesWebRepository {
    
    enum Action: Equatable {
        case countries
        case details(country: DBModel.Country)
    }
    var actions = MockActions<Action>(expected: [])
    
    var countriesResponses: [Result<[ApiModel.Country], Error>] = []
    var detailsResponses: [Result<ApiModel.CountryDetails, Error>] = []

    func countries() async throws -> [ApiModel.Country] {
        register(.countries)
        guard !countriesResponses.isEmpty else { throw MockError.valueNotSet }
        return try countriesResponses.removeFirst().get()
    }

    func details(country: DBModel.Country) async throws -> ApiModel.CountryDetails {
        register(.details(country: country))
        guard !detailsResponses.isEmpty else { throw MockError.valueNotSet }
        return try detailsResponses.removeFirst().get()
    }
}

// MARK: - ImageWebRepository

final class MockedImageWebRepository: TestWebRepository, Mock, ImagesWebRepository {

    enum Action: Equatable {
        case loadImage(URL)
    }
    var actions = MockActions<Action>(expected: [])
    
    var imageResponses: [Result<UIImage, Error>] = []

    func loadImage(url: URL) async throws -> UIImage {
        register(.loadImage(url))
        guard !imageResponses.isEmpty else { throw MockError.valueNotSet }
        return try imageResponses.removeFirst().get()
    }
}

// MARK: - PushTokenWebRepository

final class MockedPushTokenWebRepository: TestWebRepository, Mock, PushTokenWebRepository {
    enum Action: Equatable {
        case register(Data)
    }
    let actions: MockActions<Action>

    init(expected: [Action]) {
        self.actions = MockActions<Action>(expected: expected)
    }
    
    func register(devicePushToken: Data) async throws {
        register(.register(devicePushToken))
    }
}
