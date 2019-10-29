//
//  ServicesContainer.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 24.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI

struct ServicesContainer: EnvironmentKey {
    
    let countriesService: CountriesService
    
    init(countriesService: CountriesService) {
        self.countriesService = countriesService
    }
    
    static var defaultValue: ServicesContainer {
        return ServicesContainer(countriesService: FakeCountriesService())
    }
}

extension EnvironmentValues {
    var services: ServicesContainer {
        get { self[ServicesContainer.self] }
        set { self[ServicesContainer.self] = newValue }
    }
}
