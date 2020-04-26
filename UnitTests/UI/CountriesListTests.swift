//
//  CountriesListTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 01.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import ViewInspector
import SwiftUI
@testable import CountriesSwiftUI

extension CountriesList: Inspectable { }
extension ActivityIndicatorView: Inspectable { }
extension CountryCell: Inspectable { }
extension ErrorView: Inspectable { }

final class CountriesListTests: XCTestCase {

    func test_countries_notRequested() {
        let container = DIContainer(appState: AppState(), interactors:
            .mocked(
                countriesInteractor: [.loadCountries(search: "", locale: .current)]
            ))
        let sut = CountriesList(countries: .notRequested)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.content().text())
            XCTAssertEqual(container.appState.value, AppState())
            container.interactors.verify()
        }
        ViewHosting.host(view: sut.inject(container))
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_isLoading_initial() {
        let container = DIContainer(appState: AppState(), interactors: .mocked())
        let sut = CountriesList(countries: .isLoading(last: nil, cancelBag: CancelBag()))
        let exp = sut.inspection.inspect { view in
            let content = try view.content()
            XCTAssertNoThrow(try content.view(ActivityIndicatorView.self))
            XCTAssertEqual(container.appState.value, AppState())
            container.interactors.verify()
        }
        ViewHosting.host(view: sut.inject(container))
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_isLoading_refresh() {
        let container = DIContainer(appState: AppState(), interactors: .mocked())
        let sut = CountriesList(countries: .isLoading(
            last: Country.mockedData.lazyList, cancelBag: CancelBag()))
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.searchBar())
            XCTAssertNoThrow(try view.loadingIndicator())
            let cell = try view.firstRowLink()
                .label().view(CountryCell.self).actualView()
            XCTAssertEqual(cell.country, Country.mockedData[0])
            XCTAssertEqual(container.appState.value, AppState())
            container.interactors.verify()
        }
        ViewHosting.host(view: sut.inject(container))
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_loaded() {
        let container = DIContainer(appState: AppState(), interactors: .mocked())
        let sut = CountriesList(countries: .loaded(Country.mockedData.lazyList))
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.searchBar())
            XCTAssertThrowsError(try view.loadingIndicator())
            let cell = try view.firstRowLink()
                .label().view(CountryCell.self).actualView()
            XCTAssertEqual(cell.country, Country.mockedData[0])
            XCTAssertEqual(container.appState.value, AppState())
            container.interactors.verify()
        }
        ViewHosting.host(view: sut.inject(container))
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_failed() {
        let container = DIContainer(appState: AppState(), interactors: .mocked())
        let sut = CountriesList(countries: .failed(NSError.test))
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.content().view(ErrorView.self))
            XCTAssertEqual(container.appState.value, AppState())
            container.interactors.verify()
        }
        ViewHosting.host(view: sut.inject(container))
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_failed_retry() {
        let container = DIContainer(appState: AppState(), interactors: .mocked(
            countriesInteractor: [.loadCountries(search: "", locale: .current)]
        ))
        let sut = CountriesList(countries: .failed(NSError.test))
        let exp = sut.inspection.inspect { view in
            let errorView = try view.content().view(ErrorView.self)
            try errorView.vStack().button(2).tap()
            XCTAssertEqual(container.appState.value, AppState())
            container.interactors.verify()
        }
        ViewHosting.host(view: sut.inject(container))
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_navigation_to_details() {
        let countries = Country.mockedData
        let container = DIContainer(appState: AppState(), interactors: .mocked())
        XCTAssertNil(container.appState.value.routing.countriesList.countryDetails)
        let sut = CountriesList(countries: .loaded(countries.lazyList))
        let exp = sut.inspection.inspect { view in
            let firstCountryRow = try view.firstRowLink()
            try firstCountryRow.activate()
            let selected = container.appState.value.routing.countriesList.countryDetails
            XCTAssertEqual(selected, countries[0].alpha3Code)
            try firstCountryRow.view(CountryDetails.self).content().text().callOnAppear()
            container.interactors.verify()
        }
        ViewHosting.host(view: sut.inject(container))
        wait(for: [exp], timeout: 2)
    }
}

final class LocalizationTests: XCTestCase {
    func test_country_localized_name() {
        let sut = Country(name: "Abc", translations: ["fr": "Xyz"], population: 0, flag: nil, alpha3Code: "")
        let locale = Locale(identifier: "fr")
        XCTAssertEqual(sut.name(locale: locale), "Xyz")
    }
    
    func test_string_for_locale() {
        let sut = "Countries".localized(Locale(identifier: "fr"))
        XCTAssertEqual(sut, "Des pays")
    }
}

// MARK: - CountriesList inspection helper

extension InspectableView where View == ViewType.View<CountriesList> {
    func content() throws -> InspectableView<ViewType.AnyView> {
        return try geometryReader().navigationView()
            .navigationBarItems().anyView()
    }
    func searchBar() throws -> InspectableView<ViewType.View<SearchBar>> {
        return try content().vStack().view(SearchBar.self, 0)
    }
    func loadingIndicator() throws -> InspectableView<ViewType.View<ActivityIndicatorView>> {
        return try content().vStack().view(ActivityIndicatorView.self, 1)
    }
    func firstRowLink() throws -> InspectableView<ViewType.NavigationLink> {
        return try content().vStack().list(2).forEach(0).hStack(0).navigationLink(0)
    }
}
