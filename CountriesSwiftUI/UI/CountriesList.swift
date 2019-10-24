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
    var viewModel: ViewModel
    @State private var countries: Loadable<[Country]> = .notRequested
    var subscriptions = Set<AnyCancellable>()
    
    init(viewModel: ViewModel) {
        print("Rebuilt")
        self.viewModel = viewModel
        let resource = viewModel.countries.resource
        resource.assign(to: \.countries, on: self).store(in: &subscriptions)
        resource.sink { value in
            print("resource \(value)")
        }.store(in: &subscriptions)
    }
    
    var body: some View {
        print("vvv \(countries)")
        return content
            .onAppear {
                self.viewModel.loadCountries()
            }
    }
    
    // MARK: - Views
    
    private var content: AnyView {
        switch countries {
        case .notRequested: return AnyView(notRequestedView)
        case let .isLoading(last): return AnyView(loadingView(last))
        case let .loaded(countries): return AnyView(loadedView(countries))
        case let .failed(error): return AnyView(failedView(error))
        }
    }
    
    private var notRequestedView: some View {
        Text("Empty")//EmptyView()
    }
    
    private func loadingView(_ previouslyLoaded: [Country]?) -> some View {
        Text("Loading")
    }
    
    private func loadedView(_ countries: [Country]) -> some View {
        Text("Loaded")
    }
    
    private func failedView(_ error: Error) -> some View {
        Text("Error: \(error.localizedDescription)")
    }
}

extension CountriesList {
    struct ViewModel {
        private let service: CountriesServiceProtocol
        let countries: ResourceViewModel<[Country]>
        
        init(container: DIContainer) {
            service = container.countriesService
            countries = ResourceViewModel<[Country]>(
                resource: service.countries, hasDataToDisplay: {
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
                DIContainer(presetCountries: .notRequested)
            )
        )
    }
}
#endif
