//
//  MockedInteractors.swift
//  UnitTests
//
//  Created by Alexey Naumov on 07.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import SwiftUI
@testable import CountriesSwiftUI

extension InteractorsContainer {
    static func mocked(
        countriesInteractor: [MockedCountriesInteractor.Action] = []
    ) -> InteractorsContainer {
        return .init(countriesInteractor:
            MockedCountriesInteractor(expected: countriesInteractor))
    }
    
    func verify(file: StaticString = #file, line: UInt = #line) {
        (countriesInteractor as? MockedCountriesInteractor)?
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
