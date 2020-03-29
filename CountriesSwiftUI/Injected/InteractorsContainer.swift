//
//  DIContainer.Services.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 24.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

extension DIContainer {
    struct Services {
        let countriesService: CountriesService
        let imagesService: ImagesService
        
        init(countriesService: CountriesService,
             imagesService: ImagesService) {
            self.countriesService = countriesService
            self.imagesService = imagesService
        }
        
        static var stub: Self {
            .init(countriesService: StubCountriesService(),
                  imagesService: StubImagesService())
        }
    }
}
