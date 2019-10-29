//
//  InteractorsContainer.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 24.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI

struct InteractorsContainer: EnvironmentKey {
    
    let countriesInteractor: CountriesInteractor
    
    init(countriesInteractor: CountriesInteractor) {
        self.countriesInteractor = countriesInteractor
    }
    
    static var defaultValue: InteractorsContainer {
        return .init(countriesInteractor: FakeCountriesInteractor())
    }
}

extension EnvironmentValues {
    var interactors: InteractorsContainer {
        get { self[InteractorsContainer.self] }
        set { self[InteractorsContainer.self] = newValue }
    }
}
