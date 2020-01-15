//
//  CountriesList.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 24.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI
import Combine

struct CountriesList: View {
    
    private let cancelBag = CancelBag()
    
    @Environment(\.injected) private var injected: DIContainer
    @State private var countries = Countries()
    @State private var routingState: Routing = .init()
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.countriesList)
    }
    var didUpdate: ((Self) -> Void)?
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                self.content
                    .navigationBarTitle("Countries")
                    .navigationBarHidden(self.countries.isEditingSearchText)
                    .animation(.easeOut(duration: 0.3))
            }.padding(.leading, self.leadingPadding(geometry))
        }
        .onReceive(countriesUpdate) { self.countries.update($0) }
        .onReceive(routingUpdate) { self.routingState = $0 }
        .onUpdate(self, \.didUpdate)
    }
    
    private var content: AnyView {
        switch countries.filtered {
        case .notRequested: return AnyView(notRequestedView)
        case let .isLoading(last): return AnyView(loadingView(last))
        case let .loaded(countries): return AnyView(loadedView(countries, showSearch: true))
        case let .failed(error): return AnyView(failedView(error))
        }
    }
    
    private func leadingPadding(_ geometry: GeometryProxy) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            // A hack for correct display of the SplitView on iPads
            return geometry.size.width < geometry.size.height ? 0.5 : -0.5
        }
        return 0
    }
}

// MARK: - Side Effects

private extension CountriesList {
    func loadCountries() {
        injected.interactors.countriesInteractor
            .loadCountries()
            .store(in: cancelBag)
    }
}

// MARK: - Loading Content

private extension CountriesList {
    var notRequestedView: some View {
        Text("").onAppear {
            self.loadCountries()
        }
    }
    
    func loadingView(_ previouslyLoaded: [Country]?) -> some View {
        VStack {
            ActivityIndicatorView().padding()
            previouslyLoaded.map {
                loadedView($0, showSearch: false)
            }
        }
    }
    
    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            self.loadCountries()
        })
    }
}

// MARK: - Displaying Content

private extension CountriesList {
    func loadedView(_ countries: [Country], showSearch: Bool) -> some View {
        VStack {
            if showSearch {
                SearchBar(text: $countries.searchText, isEditingText: $countries.isEditingSearchText)
            }
            List(countries) { country in
                NavigationLink(
                    destination: self.detailsView(country: country),
                    tag: country.alpha3Code,
                    selection: self.routingBinding.countryDetails) {
                        CountryCell(country: country)
                    }
            }
        }
    }
    
    func detailsView(country: Country) -> some View {
        CountryDetails(country: country)
    }
}

// MARK: - Filtering Countries

extension CountriesList {
    struct Countries {
        
        private(set) var filtered: Loadable<[Country]> = .notRequested
        private var all: Loadable<[Country]> = .notRequested
        var searchText: String = "" {
            didSet { filterCountries() }
        }
        var isEditingSearchText: Bool = false
        
        mutating func update(_ countries: Loadable<[Country]>) {
            all = countries
            filterCountries()
        }
        
        private mutating func filterCountries() {
            if searchText.count == 0 {
                filtered = all
            } else {
                filtered = all.map { countries in
                    countries.filter {
                        $0.name.range(of: searchText, options: .caseInsensitive,
                                      range: nil, locale: nil) != nil
                    }
                }
            }
        }
    }
}

// MARK: - Routing

extension CountriesList {
    struct Routing: Equatable {
        var countryDetails: Country.Code?
    }
}

// MARK: - State Updates

private extension CountriesList {
    
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.countriesList)
    }
    
    var countriesUpdate: AnyPublisher<Loadable<[Country]>, Never> {
        injected.appState.updates(for: \.userData.countries)
    }
}

#if DEBUG
struct CountriesList_Previews: PreviewProvider {
    static var previews: some View {
        CountriesList().inject(.preview)
    }
}
#endif
