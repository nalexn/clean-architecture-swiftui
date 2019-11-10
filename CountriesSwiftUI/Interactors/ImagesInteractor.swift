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
    let inMemoryCache: ImageCacheRepository
    let appState: AppState
    private let memoryWarningSubscription: AnyCancellable
    
    init(webRepository: ImageWebRepository,
         inMemoryCache: ImageCacheRepository,
         memoryWarning: AnyPublisher<Void, Never>,
         appState: AppState) {
        self.webRepository = webRepository
        self.inMemoryCache = inMemoryCache
        self.appState = appState
        weak var weakInMemoryCache = inMemoryCache
        memoryWarningSubscription = memoryWarning.sink { _ in
            weakInMemoryCache?.purgeCache()
        }
    }
    
    func load(image: Binding<Loadable<UIImage>>, url: URL?) {
        guard let url = url else {
            image.wrappedValue = .notRequested; return
        }
        image.wrappedValue = .isLoading(last: image.wrappedValue.value)
        weak var weakInMemoryCache = inMemoryCache
        var keepAlive: AnyCancellable?
        keepAlive =
            inMemoryCache.cachedImage(for: url.imageCacheKey)
            .catch { _ in self.webRepository.load(imageURL: url, width: 300) }
            .sinkToLoadable {
                image.wrappedValue = $0
                if let image = $0.value {
                    weakInMemoryCache?.cache(image: image, key: url.imageCacheKey)
                }
                keepAlive = nil; _ = keepAlive
            }
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
