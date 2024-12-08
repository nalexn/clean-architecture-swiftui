//
//  MockedInteractors.swift
//  UnitTests
//
//  Created by Alexey Naumov on 07.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Testing
import SwiftUI
import ViewInspector
@testable import CountriesSwiftUI

extension DIContainer.Interactors {
    static func mocked(
        countries: [MockedCountriesInteractor.Action] = [],
        images: [MockedImagesInteractor.Action] = [],
        permissions: [MockedUserPermissionsInteractor.Action] = []
    ) -> DIContainer.Interactors {
        self.init(
            images: MockedImagesInteractor(expected: images),
            countries: MockedCountriesInteractor(expected: countries),
            userPermissions: MockedUserPermissionsInteractor(expected: permissions))
    }
    
    func verify(sourceLocation: SourceLocation = #_sourceLocation) {
        (countries as? MockedCountriesInteractor)?
            .verify(sourceLocation: sourceLocation)
        (images as? MockedImagesInteractor)?
            .verify(sourceLocation: sourceLocation)
        (userPermissions as? MockedUserPermissionsInteractor)?
            .verify(sourceLocation: sourceLocation)
    }
}

// MARK: - CountriesInteractor

struct MockedCountriesInteractor: Mock, CountriesInteractor {
    
    enum Action: Equatable {
        case refreshCountriesList
        case loadCountryDetails(country: DBModel.Country, forceReload: Bool)
    }
    
    let actions: MockActions<Action>
    var detailsResponse: Result<DBModel.CountryDetails, Error> = .failure(MockError.valueNotSet)

    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }

    func refreshCountriesList() async throws {
        register(.refreshCountriesList)
    }

    func loadCountryDetails(country: DBModel.Country, forceReload: Bool) async throws -> DBModel.CountryDetails {
        register(.loadCountryDetails(country: country, forceReload: forceReload))
        return try detailsResponse.get()
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
    
    func load(image: LoadableSubject<UIImage>, url: URL?) {
        register(.loadImage(url))
    }
}

// MARK: - ImagesInteractor

final class MockedUserPermissionsInteractor: Mock, UserPermissionsInteractor {
    
    enum Action: Equatable {
        case resolveStatus(Permission)
        case request(Permission)
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func resolveStatus(for permission: Permission) {
        register(.resolveStatus(permission))
    }
    
    func request(permission: Permission) {
        register(.request(permission))
    }
}
