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
    @ObservedObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            content
                .navigationBarTitle("Countries")
        }
    }
    
    // MARK: - Views
    
    private var content: AnyView {
        switch viewModel.content {
        case .notRequested: return AnyView(notRequestedView)
        case let .isLoading(last): return AnyView(loadingView(last))
        case let .loaded(countries): return AnyView(loadedView(countries))
        case let .failed(error): return AnyView(failedView(error))
        }
    }
    
    private var notRequestedView: some View {
        Text("").onAppear {
            self.viewModel.loadCountries()
        }
    }
    
    private func loadingView(_ previouslyLoaded: [Country]?) -> some View {
        VStack {
            Text("Loading...").padding()
            previouslyLoaded.map {
                loadedView($0)
            }
        }
    }
    
    private func loadedView(_ countries: [Country]) -> some View {
        List(countries) { country in
            CountryCell(country: country)
        }
    }
    
    private func failedView(_ error: Error) -> some View {
        VStack {
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .padding()
            Button(action: {
                self.viewModel.loadCountries()
            }, label: { Text("Retry").bold() })
        }
    }
}

extension CountriesList {
    class ViewModel: ContentViewModel<[Country]> {
        private let service: CountriesServiceProtocol
        
        init(container: DIContainer) {
            service = container.countriesService
            super.init(publisher: service.countries.eraseToAnyPublisher(), hasDataToDisplay: {
                    ($0.value?.count ?? 0) > 0
                })
        }
        
        func loadCountries() {
            service.loadCountriesList()
        }
    }
}

#if DEBUG
struct CountriesList_Previews: PreviewProvider {
    static var previews: some View {
        CountriesList(viewModel:
            CountriesList.ViewModel(container:
                DIContainer(presetCountries: .loaded(Country.sampleData))
            )
        )
    }
}
#endif
