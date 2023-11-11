//
//  CountriesListTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 01.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import ViewInspector
@testable import CountriesSwiftUI

final class CountriesListTests: XCTestCase {

    func test_countries_notRequested() {
        let container = DIContainer(appState: AppState(), services:
            .mocked(
                countriesService: [.loadCountries(search: "", locale: .current)]
            ))
        let sut = CountriesList(viewModel: .init(container: container, countries: .notRequested))
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.content().text(0))
            XCTAssertEqual(container.appState.value, AppState())
            container.services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_isLoading_initial() {
        let container = DIContainer(appState: AppState(), services: .mocked())
        let sut = CountriesList(viewModel: .init(container: container, countries:
            .isLoading(last: nil, cancelBag: CancelBag())))
        let exp = sut.inspection.inspect { view in
            let content = try view.content()
            XCTAssertNoThrow(try content.find(ActivityIndicatorView.self))
            XCTAssertEqual(container.appState.value, AppState())
            container.services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_isLoading_refresh() {
        let container = DIContainer(appState: AppState(), services: .mocked())
        let sut = CountriesList(viewModel: .init(container: container, countries:
            .isLoading(last: Country.mockedData.lazyList, cancelBag: CancelBag())))
        let exp = sut.inspection.inspect { view in
            let content = try view.content()
            XCTAssertNoThrow(try content.find(SearchBar.self))
            XCTAssertNoThrow(try content.find(ActivityIndicatorView.self))
            let cell = try content.find(CountryCell.self).actualView()
            XCTAssertEqual(cell.country, Country.mockedData[0])
            XCTAssertEqual(container.appState.value, AppState())
            container.services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_loaded() {
        let container = DIContainer(appState: AppState(), services: .mocked())
        let sut = CountriesList(viewModel: .init(container: container, countries:
            .loaded(Country.mockedData.lazyList)))
        let exp = sut.inspection.inspect { view in
            let content = try view.content()
            XCTAssertNoThrow(try content.find(SearchBar.self))
            XCTAssertThrowsError(try content.find(ActivityIndicatorView.self))
            let cell = try content.find(CountryCell.self).actualView()
            XCTAssertEqual(cell.country, Country.mockedData[0])
            XCTAssertEqual(container.appState.value, AppState())
            container.services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_failed() {
        let container = DIContainer(appState: AppState(), services: .mocked())
        let sut = CountriesList(viewModel: .init(container: container, countries:
            .failed(NSError.test)))
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.content().view(ErrorView.self, 0))
            XCTAssertEqual(container.appState.value, AppState())
            container.services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_failed_retry() {
        let container = DIContainer(appState: AppState(), services: .mocked(
            countriesService: [.loadCountries(search: "", locale: Locale(identifier: ""))]
        ))
        let sut = CountriesList(viewModel: .init(container: container, countries:
            .failed(NSError.test)))
        let exp = sut.inspection.inspect { view in
            let errorView = try view.content().view(ErrorView.self, 0)
            try errorView.vStack().button(2).tap()
            XCTAssertEqual(container.appState.value, AppState())
            container.services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_countries_navigation_to_details() {
        let countries = Country.mockedData
        let container = DIContainer(appState: AppState(), services: .mocked(
            countriesService: [.loadCountryDetails(countries[0])]
        ))
        XCTAssertNil(container.appState.value.routing.countriesList.countryDetails)
        let sut = CountriesList(viewModel: .init(container: container, countries:
            .loaded(countries.lazyList)))
        let exp = sut.inspection.inspect { view in
            let firstCountryRow = try view.content().find(ViewType.NavigationLink.self)
            try firstCountryRow.activate()
            let selected = container.appState.value.routing.countriesList.countryDetails
            XCTAssertEqual(selected, countries[0].alpha3Code)
            _ = try firstCountryRow.find(where: { try $0.callOnAppear(); return true })
            container.services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
}

final class LocalizationTests: XCTestCase {
    func test_country_localized_name() {
        let sut = Country(name: "Abc", translations: ["fr": "Xyz"], population: 0, flag: nil, alpha3Code: "")
        let locale = Locale(identifier: "fr")
        XCTAssertEqual(sut.name(locale: locale), "Xyz")
    }
    
    func test_string_for_locale() throws {
        let sut = "Countries".localized(Locale(identifier: "fr"))
        XCTAssertEqual(sut, "Des pays")
    }
}

// MARK: - CountriesList inspection helper
extension InspectableView where View == ViewType.View<CountriesList> {
    func content() throws -> InspectableView<ViewType.NavigationView> {
        return try geometryReader().navigationView()
    }
}
