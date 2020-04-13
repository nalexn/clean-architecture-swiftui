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
    
    @Environment(\.injected) private var injected: DIContainer
    @State private var countriesSearch = CountriesSearch()
    @State private(set) var countries: Loadable<[Country]> = .notRequested
    @State private var routingState: Routing = .init()
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.countriesList)
    }
    private let localeContainer = LocaleReader.Container()
    let inspection = Inspection<Self>()
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                self.content
                    .navigationBarTitle("Countries".localized(self.localeContainer.locale))
                    .navigationBarHidden(self.countriesSearch.keyboardHeight > 0)
                    .animation(.easeOut(duration: 0.3))
            }
            .modifier(NavigationViewStyle())
            .padding(.leading, self.leadingPadding(geometry))
        }
        .modifier(LocaleReader(container: localeContainer))
        .onReceive(keyboardHeightUpdate) { self.countriesSearch.keyboardHeight = $0 }
        .onReceive(routingUpdate) { self.routingState = $0 }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
    
    private var content: AnyView {
        switch countries {
        case .notRequested: return AnyView(notRequestedView)
        case let .isLoading(last, _): return AnyView(loadingView(last))
        case let .loaded(countries): return AnyView(loadedView(countries, showSearch: true, showLoading: false))
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

private extension CountriesList {
    struct NavigationViewStyle: ViewModifier {
        func body(content: Content) -> some View {
            #if targetEnvironment(macCatalyst)
            return content
            #else
            return content
                .navigationViewStyle(StackNavigationViewStyle())
            #endif
        }
    }
    
    struct LocaleReader: EnvironmentalModifier {
        
        class Container {
            var locale: Locale = .backendDefault
        }
        let container: Container
        
        // Used for triggering the update when locale changes:
        @Environment(\.locale) private var updateTrigger: Locale
        
        func resolve(in environment: EnvironmentValues) -> some ViewModifier {
            container.locale = environment.locale
            return DummyViewModifier()
        }
        
        private struct DummyViewModifier: ViewModifier {
            func body(content: Content) -> some View {
                // Cannot return just `content` because SwiftUI
                // flattens modifiers that do nothing to the `content`
                content.onAppear()
            }
        }
    }
}

// MARK: - Side Effects

private extension CountriesList {
    func reloadCountries() {
        injected.interactors.countriesInteractor
            .load(countries: $countries,
                  search: countriesSearch.searchText,
                  locale: localeContainer.locale)
    }
}

// MARK: - Loading Content

private extension CountriesList {
    var notRequestedView: some View {
        Text("").onAppear {
            self.reloadCountries()
        }
    }
    
    func loadingView(_ previouslyLoaded: [Country]?) -> some View {
        if let countries = previouslyLoaded {
            return AnyView(loadedView(countries, showSearch: true, showLoading: true))
        } else {
            return AnyView(ActivityIndicatorView().padding())
        }
    }
    
    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            self.reloadCountries()
        })
    }
}

// MARK: - Displaying Content

private extension CountriesList {
    func loadedView(_ countries: [Country], showSearch: Bool, showLoading: Bool) -> some View {
        VStack {
            if showSearch {
                SearchBar(text: $countriesSearch.searchText
                    .throttled(seconds: 0.5) { _ in
                        self.reloadCountries()
                    }
                )
            }
            if showLoading {
                ActivityIndicatorView().padding()
            }
            List(countries) { country in
                NavigationLink(
                    destination: self.detailsView(country: country),
                    tag: country.alpha3Code,
                    selection: self.routingBinding.countryDetails) {
                        CountryCell(country: country)
                    }
            }
        }.padding(.bottom, self.countriesSearch.keyboardHeight)
    }
    
    func detailsView(country: Country) -> some View {
        CountryDetails(country: country)
    }
}

// MARK: - Search State

extension CountriesList {
    struct CountriesSearch {
        var searchText: String = ""
        var keyboardHeight: CGFloat = 0
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
    
    var keyboardHeightUpdate: AnyPublisher<CGFloat, Never> {
        injected.appState.updates(for: \.system.keyboardHeight)
    }
}

#if DEBUG
struct CountriesList_Previews: PreviewProvider {
    static var previews: some View {
        CountriesList(countries: .loaded(Country.mockedData))
            .inject(.preview)
    }
}
#endif
