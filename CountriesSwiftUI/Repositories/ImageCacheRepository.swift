//
//  ImageCacheRepository.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 09.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import UIKit
import Combine

typealias ImageCacheKey = String

protocol ImageCacheRepository {
    func cache(image: UIImage, key: ImageCacheKey)
    func cachedImage(for key: ImageCacheKey) -> AnyPublisher<UIImage, ImageCacheError>
}

enum ImageCacheError: Error {
    case imageIsMissing
}

struct InMemoryImageCacheRepository: ImageCacheRepository {

    private let cache = NSCache<NSString, UIImage>()

    func cache(image: UIImage, key: ImageCacheKey) {
        cache.setObject(image, forKey: key as NSString, cost: image.estimatedSizeInKB)
    }

    func cachedImage(for key: ImageCacheKey) -> AnyPublisher<UIImage, ImageCacheError> {
        if let image = cache.object(forKey: key as NSString) {
            return Just<UIImage>(image).setFailureType(to: ImageCacheError.self).eraseToAnyPublisher()
        } else {
            return Fail<UIImage, ImageCacheError>(error: .imageIsMissing).eraseToAnyPublisher()
        }
    }

    private func removeAllImages() {
        cache.removeAllObjects()
    }
}

// MARK: - Image size

private extension UIImage {
    var estimatedSizeInKB: Int {
        let bytesPerRow = cgImage?.bytesPerRow ?? Int(size.width * scale) * 4
        let numberOfRows = Int(size.height * scale)
        return bytesPerRow / 1024 * numberOfRows
    }
}
