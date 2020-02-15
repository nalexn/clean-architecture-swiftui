//
//  MockedInteractors.swift
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

extension DIContainer.Interactors {
    static func mocked(
        countriesInteractor: [MockedCountriesInteractor.Action] = [],
        imagesInteractor: [MockedImagesInteractor.Action] = []
    ) -> DIContainer.Interactors {
        .init(countriesInteractor: MockedCountriesInteractor(expected: countriesInteractor),
              imagesInteractor: MockedImagesInteractor(expected: imagesInteractor))
    }
    
    func verify(file: StaticString = #file, line: UInt = #line) {
        (countriesInteractor as? MockedCountriesInteractor)?
            .verify(file: file, line: line)
        (imagesInteractor as? MockedImagesInteractor)?
            .verify(file: file, line: line)
    }
}

// MARK: - CountriesInteractor

struct MockedCountriesInteractor: Mock, CountriesInteractor {
    
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
    
    func load(countryDetails: Binding<Loadable<Country.Details>>, country: Country) {
        register(.loadCountryDetails(country))
    }
}

// MARK: - ImagesInteractor

struct MockedImagesInteractor: Mock, ImagesInteractor {
    
    enum Action: Equatable {
        case loadImage(URL?)
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func load(image: Binding<Loadable<UIImage>>, url: URL?) {
        register(.loadImage(url))
    }
}
