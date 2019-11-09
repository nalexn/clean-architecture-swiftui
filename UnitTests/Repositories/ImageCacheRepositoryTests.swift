//
//  ImageCacheRepositoryTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 10.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
@testable import CountriesSwiftUI

class ImageCacheRepositoryTests: XCTestCase {
    var sut: InMemoryImageCacheRepository!
    
    override func setUp() {
        sut = InMemoryImageCacheRepository()
    }
    
    func test_cachedImage_imageIsMissing() {
        let exp = XCTestExpectation(description: "Completion")
        _ = sut.cachedImage(for: "missing_file").sinkResult { result in
            result.assertFailure(ImageCacheError.imageIsMissing.localizedDescription)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_cacheImage_cachedImage() {
        let image = UIColor.red.image(CGSize(width: 50, height: 50))
        let key = "image_key"
        sut.cache(image: image, key: key)
        let exp = XCTestExpectation(description: "Completion")
        _ = sut.cachedImage(for: key).sinkResult { result in
            result.assertSuccess(value: image)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_purgeCache() {
        let image = UIColor.red.image(CGSize(width: 50, height: 50))
        let key = "image_key"
        sut.cache(image: image, key: key)
        sut.purgeCache()
        let exp = XCTestExpectation(description: "Completion")
        _ = sut.cachedImage(for: key).sinkResult { result in
            result.assertFailure(ImageCacheError.imageIsMissing.localizedDescription)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    /*
     func cache(image: UIImage, key: ImageCacheKey)
     func cachedImage(for key: ImageCacheKey) -> AnyPublisher<UIImage, ImageCacheError>
     func purgeCache()
     */
}
