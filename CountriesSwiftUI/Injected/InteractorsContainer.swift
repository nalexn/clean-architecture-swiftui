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
    let imagesInteractor: ImagesInteractor
    
    init(countriesInteractor: CountriesInteractor,
         imagesInteractor: ImagesInteractor) {
        self.countriesInteractor = countriesInteractor
        self.imagesInteractor = imagesInteractor
    }
    
    static var defaultValue: InteractorsContainer {
        return .init(countriesInteractor: StubCountriesInteractor(),
                     imagesInteractor: StubImagesInteractor())
    }
}

extension EnvironmentValues {
    var interactors: InteractorsContainer {
        get { self[InteractorsContainer.self] }
        set { self[InteractorsContainer.self] = newValue }
    }
}
