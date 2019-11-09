//
//  ImagesInteractor.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 09.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

protocol ImagesInteractor {
    func load(image: Binding<Loadable<UIImage>>, url: URL?)
}

struct RealImagesInteractor: ImagesInteractor {
    
    let webRepository: ImageWebRepository
    let inMemoryCacheRepository: ImageCacheRepository
    let appState: AppState
    private let memoryWarningSubscription: AnyCancellable
    
    init(webRepository: ImageWebRepository,
         inMemoryCacheRepository: ImageCacheRepository,
         memoryWarning: AnyPublisher<Void, Never>,
         appState: AppState) {
        self.webRepository = webRepository
        self.inMemoryCacheRepository = inMemoryCacheRepository
        self.appState = appState
        weak var weakInMemoryCache = inMemoryCacheRepository
        memoryWarningSubscription = memoryWarning.sink { _ in
            weakInMemoryCache?.purgeCache()
        }
    }
    
    func load(image: Binding<Loadable<UIImage>>, url: URL?) {
        guard let url = url else {
            image.wrappedValue = .notRequested; return
        }
        image.wrappedValue = .isLoading(last: image.wrappedValue.value)
        weak var weakAppState = appState
        weak var weakInMemoryCache = inMemoryCacheRepository
        let token =
            inMemoryCacheRepository.cachedImage(for: url.imageCacheKey)
            .catch { _ in self.webRepository.load(imageURL: url, width: 300) }
            .sinkToLoadable {
                image.wrappedValue = $0
                if let image = $0.value {
                    weakInMemoryCache?.cache(image: image, key: url.imageCacheKey)
                }
                weakAppState?.system.runningRequests[url] = nil
            }
        appState.system.runningRequests[url] = token
    }
}

extension URL {
    var imageCacheKey: ImageCacheKey {
        return absoluteString
    }
}

struct StubImagesInteractor: ImagesInteractor {
    func load(image: Binding<Loadable<UIImage>>, url: URL?) {
    }
}
