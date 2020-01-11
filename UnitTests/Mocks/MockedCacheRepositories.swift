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

// MARK: - ImageCacheRepository

class MockedImageCacheRepository: ImageCacheRepository, Mock {
    
    var actions = MockActions<MockedImageWebRepository.Action>(expected: [])
    
    var imageResponse: Result<UIImage, ImageCacheError> = .failure(.imageIsMissing)
    var cached: [ImageCacheKey: UIImage] = [:]
    var didCallPurgeCache = false
    
    func cache(image: UIImage, key: ImageCacheKey) {
        cached[key] = image
    }
    
    func cachedImage(for key: ImageCacheKey) -> AnyPublisher<UIImage, ImageCacheError> {
        register(.loadImage(URL(string: key)))
        return imageResponse.publish()
    }
    
    func purgeCache() {
        didCallPurgeCache = true
    }
}
