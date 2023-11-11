//
//  CountriesServiceTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 31.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import SwiftUI
import Combine
@testable import CountriesSwiftUI

class CountriesServiceTests: XCTestCase {

    let appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedWebRepo: MockedCountriesWebRepository!
    var mockedDBRepo: MockedCountriesDBRepository!
    var subscriptions = Set<AnyCancellable>()
    var sut: RealCountriesService!

    override func setUp() {
        appState.value = AppState()
        mockedWebRepo = MockedCountriesWebRepository()
        mockedDBRepo = MockedCountriesDBRepository()
        sut = RealCountriesService(webRepository: mockedWebRepo,
                                      dbRepository: mockedDBRepo,
                                      appState: appState)
    }

    override func tearDown() {
        subscriptions = Set<AnyCancellable>()
    }
}

// MARK: - load(countries: search: locale:)
final class LoadCountriesTests: CountriesServiceTests {
    
    func test_filledDB_successfulSearch() {
        let list = Country.mockedData
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
        ])
        mockedDBRepo.actions = .init(expected: [
            .hasLoadedCountries,
            .fetchCountries(search: "abc", locale: .backendDefault)
        ])
        
        // Configuring responses from repositories
        
        mockedDBRepo.hasLoadedCountriesResult = .success(true)
        mockedDBRepo.fetchCountriesResult = .success(list.lazyList)
        
        let countries = BindingWithPublisher(value: Loadable<LazyList<Country>>.notRequested)
        sut.load(countries: countries.binding, search: "abc", locale: .backendDefault)
        let exp = XCTestExpectation(description: #function)
        countries.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: .test),
                .loaded(list.lazyList)
            ], removing: Country.prefixes)
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_filledDB_failedSearch() {
        let error = NSError.test
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
        ])
        mockedDBRepo.actions = .init(expected: [
            .hasLoadedCountries,
            .fetchCountries(search: "abc", locale: .backendDefault)
        ])
        
        // Configuring responses from repositories
        
        mockedDBRepo.hasLoadedCountriesResult = .success(true)
        mockedDBRepo.fetchCountriesResult = .failure(error)
        
        let countries = BindingWithPublisher(value: Loadable<LazyList<Country>>.notRequested)
        sut.load(countries: countries.binding, search: "abc", locale: .backendDefault)
        let exp = XCTestExpectation(description: #function)
        countries.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: .test),
                .failed(error)
            ], removing: Country.prefixes)
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_emptyDB_failedRequest() {
        let error = NSError.test
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .loadCountries
        ])
        mockedDBRepo.actions = .init(expected: [
            .hasLoadedCountries
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.countriesResponse = .failure(error)
        mockedDBRepo.hasLoadedCountriesResult = .success(false)
        
        let countries = BindingWithPublisher(value: Loadable<LazyList<Country>>.notRequested)
        sut.load(countries: countries.binding, search: "abc", locale: .backendDefault)
        let exp = XCTestExpectation(description: #function)
        countries.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: .test),
                .failed(error)
            ], removing: Country.prefixes)
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_emptyDB_successfulRequest_successfulStoring() {
        let list = Country.mockedData
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .loadCountries
        ])
        mockedDBRepo.actions = .init(expected: [
            .hasLoadedCountries,
            .storeCountries(list),
            .fetchCountries(search: "abc", locale: .backendDefault)
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.countriesResponse = .success(list)
        mockedDBRepo.hasLoadedCountriesResult = .success(false)
        mockedDBRepo.storeCountriesResult = .success(())
        mockedDBRepo.fetchCountriesResult = .success(list.lazyList)
        
        let countries = BindingWithPublisher(value: Loadable<LazyList<Country>>.notRequested)
        sut.load(countries: countries.binding, search: "abc", locale: .backendDefault)
        let exp = XCTestExpectation(description: #function)
        countries.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: .test),
                .loaded(list.lazyList)
            ], removing: Country.prefixes)
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_emptyDB_successfulRequest_failedStoring() {
        let list = Country.mockedData
        let error = NSError.test
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .loadCountries
        ])
        mockedDBRepo.actions = .init(expected: [
            .hasLoadedCountries,
            .storeCountries(list)
        ])
        
        // Configuring responses from repositories
        
        mockedWebRepo.countriesResponse = .success(list)
        mockedDBRepo.hasLoadedCountriesResult = .success(false)
        mockedDBRepo.storeCountriesResult = .failure(error)
        
        let countries = BindingWithPublisher(value: Loadable<LazyList<Country>>.notRequested)
        sut.load(countries: countries.binding, search: "abc", locale: .backendDefault)
        let exp = XCTestExpectation(description: #function)
        countries.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: .test),
                .failed(error)
            ], removing: Country.prefixes)
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
}

// MARK: - load(countryDetails: country: )
final class LoadCountryDetailsTests: CountriesServiceTests {
    
    func test_filledDB_successfulSearch() {
        let country = Country.mockedData[0]
        let data = countryDetails(neighbors: [])
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
        ])
        mockedDBRepo.actions = .init(expected: [
            .fetchCountryDetails(country)
        ])
        
        // Configuring responses from repositories
        
        mockedDBRepo.fetchCountryDetailsResult = .success(data.details)
        
        let details = BindingWithPublisher(value: Loadable<Country.Details>.notRequested)
        sut.load(countryDetails: details.binding, country: country)
        let exp = XCTestExpectation(description: #function)
        details.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: .test),
                .loaded(data.details)
            ], removing: Country.prefixes)
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_filledDB_dataNotFound_failedRequest() {
        let country = Country.mockedData[0]
        let error = NSError.test
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .loadCountryDetails(country)
        ])
        mockedDBRepo.actions = .init(expected: [
            .fetchCountryDetails(country)
        ])
        
        // Configuring responses from repositories
        
        mockedDBRepo.fetchCountryDetailsResult = .success(nil)
        mockedWebRepo.detailsResponse = .failure(error)
        
        let details = BindingWithPublisher(value: Loadable<Country.Details>.notRequested)
        sut.load(countryDetails: details.binding, country: country)
        let exp = XCTestExpectation(description: #function)
        details.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: .test),
                .failed(error)
            ], removing: Country.prefixes)
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_filledDB_dataNotFound_successfulRequest_failedStoring() {
        let country = Country.mockedData[0]
        let data = countryDetails(neighbors: [])
        let error = NSError.test
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .loadCountryDetails(country)
        ])
        mockedDBRepo.actions = .init(expected: [
            .fetchCountryDetails(country),
            .storeCountryDetails(data.intermediate)
        ])
        
        // Configuring responses from repositories
        
        mockedDBRepo.fetchCountryDetailsResult = .success(nil)
        mockedWebRepo.detailsResponse = .success(data.intermediate)
        mockedDBRepo.storeCountryDetailsResult = .failure(error)
        
        let details = BindingWithPublisher(value: Loadable<Country.Details>.notRequested)
        sut.load(countryDetails: details.binding, country: country)
        let exp = XCTestExpectation(description: #function)
        details.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: .test),
                .failed(error)
            ], removing: Country.prefixes)
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_filledDB_dataNotFound_successfulRequest_successfulStoring() {
        let country = Country.mockedData[0]
        let data = countryDetails(neighbors: [])
        
        // Configuring expected actions on repositories
        
        mockedWebRepo.actions = .init(expected: [
            .loadCountryDetails(country)
        ])
        mockedDBRepo.actions = .init(expected: [
            .fetchCountryDetails(country),
            .storeCountryDetails(data.intermediate)
        ])
        
        // Configuring responses from repositories
        
        mockedDBRepo.fetchCountryDetailsResult = .success(nil)
        mockedWebRepo.detailsResponse = .success(data.intermediate)
        mockedDBRepo.storeCountryDetailsResult = .success(data.details)
        
        let details = BindingWithPublisher(value: Loadable<Country.Details>.notRequested)
        sut.load(countryDetails: details.binding, country: country)
        let exp = XCTestExpectation(description: #function)
        details.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: .test),
                .loaded(data.details)
            ], removing: Country.prefixes)
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_stubService() {
        let sut = StubCountriesService()
        let countries = BindingWithPublisher(value: Loadable<LazyList<Country>>.notRequested)
        sut.load(countries: countries.binding, search: "", locale: .backendDefault)
        let details = BindingWithPublisher(value: Loadable<Country.Details>.notRequested)
        sut.load(countryDetails: details.binding, country: Country.mockedData[0])
    }
    
    // MARK: - Helper
    
    private func recordAppStateUserDataUpdates(for timeInterval: TimeInterval = 0.5)
        -> AnyPublisher<[AppState.UserData], Never> {
        return Future<[AppState.UserData], Never> { (completion) in
            var updates = [AppState.UserData]()
            self.appState.map(\.userData)
                .sink { updates.append($0 )}
                .store(in: &self.subscriptions)
            DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
                completion(.success(updates))
            }
        }.eraseToAnyPublisher()
    }
    
    private func countryDetails(neighbors: [Country])
        -> (intermediate: Country.Details.Intermediate, details: Country.Details) {
        let intermediate = Country.Details.Intermediate(
            capital: "London",
            currencies: [Country.Currency(code: "12", symbol: "$", name: "US dollar")],
            borders: neighbors.map { $0.alpha3Code })
        let details = Country.Details(capital: intermediate.capital,
                                      currencies: intermediate.currencies,
                                      neighbors: neighbors)
        return (intermediate, details)
    }
}

extension Country: PrefixRemovable { }
extension Country.Details: PrefixRemovable { }
