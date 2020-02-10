//
//  CountryDetails.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 25.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI
import Combine

struct CountryDetails: View {
    
    let country: Country
    private let cancelBag = CancelBag()
    
    @Environment(\.locale) var locale: Locale
    @Environment(\.injected) private var injected: DIContainer
    @State private var details: Loadable<Country.Details>
    @State private var routingState: Routing = .init()
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.countryDetails)
    }
    let inspection = Inspection<Self>()
    
    init(country: Country, details: Loadable<Country.Details> = .notRequested) {
        self.country = country
        self._details = .init(initialValue: details)
    }
    
    var body: some View {
        content
            .navigationBarTitle(country.name(locale: locale))
            .modifier(NavigationBarBugFixer(goBack: self.goBack))
            .onReceive(routingUpdate) { self.routingState = $0 }
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
    
    private var content: AnyView {
        switch details {
        case .notRequested: return AnyView(notRequestedView)
        case .isLoading: return AnyView(loadingView)
        case let .loaded(countryDetails): return AnyView(loadedView(countryDetails))
        case let .failed(error): return AnyView(failedView(error))
        }
    }
}

// MARK: - Side Effects

private extension CountryDetails {
    func loadCountryDetails() {
        injected.interactors.countriesInteractor
            .load(countryDetails: $details, country: country)
            .store(in: cancelBag)
    }
    
    func showCountryDetailsSheet() {
        injected.appState[\.routing.countryDetails.detailsSheet] = true
    }
    
    func goBack() {
        injected.appState[\.routing.countriesList.countryDetails] = nil
    }
}

// MARK: - Loading Content

private extension CountryDetails {
    var notRequestedView: some View {
        Text("").onAppear {
            self.loadCountryDetails()
        }
    }
    
    var loadingView: some View {
        ActivityIndicatorView()
    }
    
    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            self.loadCountryDetails()
        })
    }
}

// MARK: - A workaround for a bug in NavigationBar
// https://stackoverflow.com/q/58404725/2923345

private struct NavigationBarBugFixer: ViewModifier {
        
    let goBack: () -> Void
    
    func body(content: Content) -> some View {
        #if targetEnvironment(simulator)
        let isiPhoneSimulator = UIDevice.current.userInterfaceIdiom == .phone
        return Group {
            if ProcessInfo.processInfo.isRunningTests {
                content
            } else {
                content
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(leading: Button(action: {
                        print("Please note that NavigationView currently does not work correctly on the iOS Simulator.")
                        self.goBack()
                    }, label: { Text(isiPhoneSimulator ? "Back" : "") }))
            }
        }
        #else
        return content
        #endif
    }
}

// MARK: - Displaying Content

private extension CountryDetails {
    func loadedView(_ countryDetails: Country.Details) -> some View {
        List {
            country.flag.map { url in
                flagView(url: url)
            }
            basicInfoSectionView(countryDetails: countryDetails)
            if countryDetails.currencies.count > 0 {
                currenciesSectionView(currencies: countryDetails.currencies)
            }
            if countryDetails.neighbors.count > 0 {
                neighborsSectionView(neighbors: countryDetails.neighbors)
            }
        }
        .listStyle(GroupedListStyle())
        .sheet(isPresented: routingBinding.detailsSheet,
               content: { self.modalDetailsView() })
    }
    
    func flagView(url: URL) -> some View {
        HStack {
            Spacer()
            SVGImageView(imageURL: url)
                .frame(width: 120, height: 80)
                .onTapGesture {
                    self.showCountryDetailsSheet()
                }
            Spacer()
        }
    }
    
    func basicInfoSectionView(countryDetails: Country.Details) -> some View {
        Section(header: Text("Basic Info")) {
            DetailRow(leftLabel: Text(country.alpha3Code), rightLabel: "Code")
            DetailRow(leftLabel: Text("\(country.population)"), rightLabel: "Population")
            DetailRow(leftLabel: Text("\(countryDetails.capital)"), rightLabel: "Capital")
        }
    }
    
    func currenciesSectionView(currencies: [Country.Currency]) -> some View {
        Section(header: Text("Currencies")) {
            ForEach(currencies) { currency in
                DetailRow(leftLabel: Text(currency.title), rightLabel: Text(currency.code))
            }
        }
    }
    
    func neighborsSectionView(neighbors: [Country]) -> some View {
        Section(header: Text("Neighboring countries")) {
            ForEach(neighbors) { country in
                NavigationLink(destination: self.neighbourDetailsView(country: country)) {
                    DetailRow(leftLabel: Text(country.name(locale: self.locale)), rightLabel: "")
                }
            }
        }
    }
    
    func neighbourDetailsView(country: Country) -> some View {
        CountryDetails(country: country)
    }
    
    func modalDetailsView() -> some View {
        ModalDetailsView(country: country,
                         isDisplayed: routingBinding.detailsSheet)
            .inject(injected)
    }
}

// MARK: - Helpers

private extension Country.Currency {
    var title: String {
        return name + (symbol.map {" " + $0} ?? "")
    }
}

// MARK: - Routing

extension CountryDetails {
    struct Routing: Equatable {
        var detailsSheet: Bool = false
    }
}

// MARK: - State Updates

private extension CountryDetails {
    
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.countryDetails)
    }
}

// MARK: - Preview

#if DEBUG
struct CountryDetails_Previews: PreviewProvider {
    static var previews: some View {
        CountryDetails(country: Country.mockedData[0])
            .inject(.preview)
    }
}
#endif
