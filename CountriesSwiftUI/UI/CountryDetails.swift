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
    let viewModel: ViewModel
    
    var body: some View {
        content
            .onAppear {
                self.viewModel.loadCountryDetails()
            }
    }
    
    private var content: some View {
        Text(viewModel.country.name)
            .navigationBarTitle(viewModel.country.name)
    }
}


extension CountryDetails {
    class ViewModel: ContentViewModel<Country.Details> {
        
        let country: Country
        private let container: DIContainer
        private let details = CurrentValueSubject<Loadable<Country.Details>, Never>(.notRequested)
        private var requestToken: Cancellable?
        
        init(container: DIContainer, country: Country) {
            self.container = container
            self.country = country
            super.init(publisher: details.eraseToAnyPublisher(),
                       hasDataToDisplay: { $0.value != nil })
        }
        
        func loadCountryDetails() {
            requestToken?.cancel()
            requestToken = container.countriesService
                .load(countryDetails: details, country: country)
        }
    }
}

#if DEBUG
struct CountryDetails_Previews: PreviewProvider {
    static var previews: some View {
        CountryDetails(viewModel:
            CountryDetails.ViewModel(container:
                DIContainer(presetCountries: .loaded(Country.sampleData)),
                                     country: Country.sampleData[0]
            )
        )
    }
}
#endif
