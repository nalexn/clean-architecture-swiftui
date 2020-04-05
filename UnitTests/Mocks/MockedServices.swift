//
//  MockedServices.swift
//  UnitTests
//
//  Created by Alexey Naumov on 07.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import SwiftUI
import Combine
import ViewInspector
@testable import CountriesSwiftUI

extension DIContainer.Services {
    static func mocked(
        countriesService: [MockedCountriesService.Action] = [],
        imagesService: [MockedImagesService.Action] = []
    ) -> DIContainer.Services {
        .init(countriesService: MockedCountriesService(expected: countriesService),
              imagesService: MockedImagesService(expected: imagesService))
    }
    
    func verify(file: StaticString = #file, line: UInt = #line) {
        (countriesService as? MockedCountriesService)?
            .verify(file: file, line: line)
        (imagesService as? MockedImagesService)?
            .verify(file: file, line: line)
    }
}

// MARK: - CountriesService

struct MockedCountriesService: Mock, CountriesService {
    
    enum Action: Equatable {
        case loadCountries
        case loadCountryDetails(Country)
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func loadCountries() {
        register(.loadCountries)
    }
    
    func load(countryDetails: LoadableSubject<Country.Details>, country: Country) {
        register(.loadCountryDetails(country))
    }
}

// MARK: - ImagesService

struct MockedImagesService: Mock, ImagesService {
    
    enum Action: Equatable {
        case loadImage(URL?)
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func load(image: LoadableSubject<UIImage>, url: URL?) {
        register(.loadImage(url))
    }
}
