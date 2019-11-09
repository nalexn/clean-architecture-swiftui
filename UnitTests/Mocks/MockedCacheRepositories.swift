//
//  MockedCacheRepositories.swift
//  UnitTests
//
//  Created by Alexey Naumov on 10.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import Combine
@testable import CountriesSwiftUI

// MARK: - InMemoryImageCacheRepository

class MockedInMemoryImageCacheRepository: ImageCacheRepository {
    
    var imageResponse: Result<UIImage, ImageCacheError> = .failure(.imageIsMissing)
    var cached: [ImageCacheKey: UIImage] = [:]
    var didCallPurgeCache = false
    
    func cache(image: UIImage, key: ImageCacheKey) {
        cached[key] = image
    }
    
    func cachedImage(for key: ImageCacheKey) -> AnyPublisher<UIImage, ImageCacheError> {
        return imageResponse.publish()
    }
    
    func purgeCache() {
        didCallPurgeCache = true
    }
}
