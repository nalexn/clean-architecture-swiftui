//
//  ContentView.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let container: DIContainer
    
    var body: some View {
        CountriesList(viewModel:
            CountriesList.ViewModel(container: container)
        )
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(container: DIContainer(presetCountries: .notRequested))
    }
}
#endif
