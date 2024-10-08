//
//  DIContainer.Services.swift
//  Orbit
//
//  Created by Alexey Naumov on 24.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

extension DIContainer {
    struct Services {
        let countriesService: CountriesService
        let imagesService: ImagesService
        let userPermissionsService: UserPermissionsService
        let appwriteService: AppwriteServiceProtocol
        let accountManagementService: AccountManagementServiceProtocol

        init(
            countriesService: CountriesService,
            imagesService: ImagesService,
            userPermissionsService: UserPermissionsService,
            appwriteService: AppwriteService,
            accountManagementService: AccountManagementServiceProtocol
        ) {
            self.countriesService = countriesService
            self.imagesService = imagesService
            self.userPermissionsService = userPermissionsService
            self.appwriteService = appwriteService
            self.accountManagementService = AccountManagementService()
        }

        static var stub: Self {
            .init(
                countriesService: StubCountriesService(),
                imagesService: StubImagesService(),
                userPermissionsService: StubUserPermissionsService(),
                appwriteService: AppwriteService(),
                accountManagementService: AccountManagementService()
            )
        }
    }
}
