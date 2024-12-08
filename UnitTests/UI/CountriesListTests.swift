//
//  CountriesListTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 01.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Testing
import ViewInspector
import SwiftData
import SwiftUI
@testable import CountriesSwiftUI

@MainActor
@Suite struct CountriesListTests {

    let apiCountries: [ApiModel.Country]
    let dbCountries: [DBModel.Country]

    init() {
        apiCountries = ApiModel.Country.mockedData
        dbCountries = apiCountries.map { $0.dbModel() }
    }

    @Test func noCachedCountries() async throws {
        let container = DIContainer(interactors: .mocked(countries: [
            .refreshCountriesList,
        ]))
        let sut = CountriesList(state: .notRequested)
        try await ViewHosting.host(sut.inject(container)) {
            try await sut.inspection.inspect { view in
                #expect(container.appState.value == AppState())
                container.interactors.verify()
            }
        }
    }

    @Test func cachedCountries() async throws {
        let container = DIContainer(interactors: .mocked())
        let sut = CountriesList(state: .notRequested)
        let modelContainer = ModelContainer.mock
        let dbRepository = MainDBRepository(modelContainer: modelContainer)
        try await dbRepository.store(countries: apiCountries)
        let view = sut.inject(container).modelContainer(modelContainer)
        try await ViewHosting.host(view) {
            try await sut.inspection.inspect { view in
                #expect(container.appState.value == AppState())
                container.interactors.verify()
            }
        }
    }

    @Test func noMatchesWhenSearching() async throws {
        let container = DIContainer(interactors: .mocked())
        let sut = CountriesList(state: .loaded(()))
        let modelContainer = ModelContainer.mock
        let dbRepository = MainDBRepository(modelContainer: modelContainer)
        try await dbRepository.store(countries: apiCountries)
        let view = sut.inject(container).modelContainer(modelContainer)
        try await ViewHosting.host(view) {
            try await sut.inspection.inspect { view in
                try view.actualView().searchText = "whatever"
            }
            try await sut.inspection.inspect { view in
                #expect(throws: Never.self) { try view.find(text: "No matches found") }
                container.interactors.verify()
            }
        }
    }

    @Test func listRefresh() async throws {
        let container = DIContainer(interactors: .mocked(countries: [
            .refreshCountriesList
        ]))
        let sut = CountriesList(state: .loaded(()))
        let modelContainer = ModelContainer.mock
        let dbRepository = MainDBRepository(modelContainer: modelContainer)
        try await dbRepository.store(countries: apiCountries)
        let view = sut.inject(container).modelContainer(modelContainer)
        try await ViewHosting.host(view) {
            try await sut.inspection.inspect { view in
                let list = try view.find(ViewType.List.self)
                try await list.callRefreshable()
                container.interactors.verify()
            }
        }
    }

    @Test func countriesIsLoadingInitial() async throws {
        let container = DIContainer(interactors: .mocked())
        let sut = CountriesList(state: .isLoading(last: nil, cancelBag: .test))
        try await ViewHosting.host(sut.inject(container)) {
            try await sut.inspection.inspect { view in
                let content = try view.content()
                #expect(throws: Never.self) { try content.find(ViewType.ProgressView.self) }
                #expect(container.appState.value == AppState())
                container.interactors.verify()
            }
        }
    }

    @Test func countriesLoaded() async throws {
        let container = DIContainer(interactors: .mocked())
        let sut = CountriesList(state: .loaded(()))
        let modelContainer = ModelContainer.mock
        let dbRepository = MainDBRepository(modelContainer: modelContainer)
        try await dbRepository.store(countries: apiCountries)
        let view = sut.inject(container).modelContainer(modelContainer)
        let firstRowCountry = try #require(dbCountries.sorted(by: { $0.name < $1.name }).first)
        try await ViewHosting.host(view) {
            try await sut.inspection.inspect { view in
                let content = try view.content()
                #expect(throws: (any Error).self) { try content.find(ViewType.ProgressView.self) }
                let cell = try content.find(CountryCell.self).actualView()
                #expect(cell.country.name == firstRowCountry.name)
                #expect(container.appState.value == AppState())
                container.interactors.verify()
            }
        }
    }
    
    @Test func countriesFailed() async throws {
        let container = DIContainer(interactors: .mocked())
        let sut = CountriesList(state: .failed(NSError.test))
        try await ViewHosting.host(sut.inject(container)) {
            try await sut.inspection.inspect { view in
                #expect(throws: Never.self) { try view.content().implicitAnyView().implicitAnyView().implicitAnyView().view(ErrorView.self, 0) }
                #expect(container.appState.value == AppState())
                container.interactors.verify()
            }
        }
    }
    
    @Test func countriesFailedRetry() async throws {
        let container = DIContainer(interactors: .mocked())
        let sut = CountriesList(state: .failed(NSError.test))
        try await ViewHosting.host(sut.inject(container)) {
            try await sut.inspection.inspect { view in
                let errorView = try view.content().implicitAnyView().implicitAnyView().implicitAnyView().view(ErrorView.self, 0)
                try errorView.implicitAnyView().vStack().button(2).tap()
                #expect(container.appState.value == AppState())
                container.interactors.verify()
            }
        }
    }

    @Test func requestPush() async throws {
        let container = DIContainer(interactors: .mocked(permissions: [
            .request(.pushNotifications)
        ]))
        container.appState[\.permissions.push] = .notRequested
        let sut = CountriesList(state: .loaded(()))
        try await ViewHosting.host(sut.inject(container)) {
            try await sut.inspection.inspect { view in
                try view.find(button: "Allow Push").tap()
                container.interactors.verify()
            }
        }
    }
}

@Suite struct LocalizationTests {

    @Test func countryLocalizedName() {
        let sut = DBModel.Country(name: "Abc", translations: ["fr": "Xyz"], population: 0, flag: nil, alpha3Code: "")
        let locale = Locale(identifier: "fr")
        #expect(sut.name(locale: locale) == "Xyz")
    }
}

// MARK: - CountriesList inspection helper

extension InspectableView where View == ViewType.View<CountriesList> {
    func content() throws -> InspectableView<ViewType.NavigationStack> {
        return try implicitAnyView().navigationStack()
    }
}
