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
    
    @ObservedObject private(set) var viewModel: ViewModel
    @Environment(\.locale) private var locale: Locale
    let inspection = Inspection<Self>()
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                self.content
                    .navigationBarTitle("Countries".localized(self.locale))
                    .navigationBarHidden(self.viewModel.countriesSearch.keyboardHeight > 0)
                    .animation(.easeOut(duration: 0.3))
            }
            .modifier(NavigationViewStyle())
            .padding(.leading, self.leadingPadding(geometry))
        }
        .modifier(viewModel.localeReader)
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
    
    private var content: AnyView {
        switch viewModel.countries {
        case .notRequested:
            return AnyView(notRequestedView)
        case let .isLoading(last, _):
            return AnyView(loadingView(last))
        case let .loaded(countries):
            return AnyView(loadedView(countries, showSearch: true, showLoading: false))
        case let .failed(error):
            return AnyView(failedView(error))
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
}

// MARK: - Loading Content

private extension CountriesList {
    var notRequestedView: some View {
        Text("").onAppear {
            self.viewModel.reloadCountries()
        }
    }
    
    func loadingView(_ previouslyLoaded: LazyList<Country>?) -> some View {
        if let countries = previouslyLoaded {
            return AnyView(loadedView(countries, showSearch: true, showLoading: true))
        } else {
            return AnyView(ActivityIndicatorView().padding())
        }
    }
    
    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            self.viewModel.reloadCountries()
        })
    }
}

// MARK: - Displaying Content

private extension CountriesList {
    func loadedView(_ countries: LazyList<Country>, showSearch: Bool, showLoading: Bool) -> some View {
        VStack {
            if showSearch {
                SearchBar(text: $viewModel.countriesSearch.searchText.onSet({ _ in
                    self.viewModel.reloadCountries()
                }))
            }
            if showLoading {
                ActivityIndicatorView().padding()
            }
            List(countries) { country in
                NavigationLink(
                    destination: self.detailsView(country: country),
                    tag: country.alpha3Code,
                    selection: self.$viewModel.routingState.countryDetails) {
                        CountryCell(country: country)
                    }
            }
        }.padding(.bottom, self.viewModel.countriesSearch.keyboardHeight)
    }
    
    func detailsView(country: Country) -> some View {
        CountryDetails(viewModel: .init(container: viewModel.container, country: country))
    }
}

// MARK: - Preview

#if DEBUG
struct CountriesList_Previews: PreviewProvider {
    static var previews: some View {
        CountriesList(viewModel: .init(container: .preview))
    }
}
#endif
