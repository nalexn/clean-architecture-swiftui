//
//  ImagesService.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 09.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

protocol ImagesService {
    func load(image: LoadableSubject<UIImage>, url: URL?)
}

struct ImageCache {
    private let cache = NSCache<NSURL, UIImage>()

    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}

struct RealImagesService: ImagesService {

    let webRepository: ImageWebRepository
    var imageCache: ImageCache

    init(webRepository: ImageWebRepository) {
        self.webRepository = webRepository
        self.imageCache = ImageCache()
    }

    func load(image: LoadableSubject<UIImage>, url: URL?) {
        guard let url = url else {
            image.wrappedValue = .notRequested; return
        }
        let cancelBag = CancelBag()
        if let caсhedImage = imageCache[url] {
            image.wrappedValue = .loaded(caсhedImage)
        }
        else {
            image.wrappedValue = .isLoading(last: image.wrappedValue.value, cancelBag: cancelBag)
            var cache = self.imageCache
            webRepository.load(imageURL: url, width: 300)
                .sinkToLoadable {
                    image.wrappedValue = $0
                    cache[url] = $0.value
            }
            .store(in: cancelBag)
        }
    }
}

struct StubImagesService: ImagesService {
    func load(image: LoadableSubject<UIImage>, url: URL?) {
    }
}
