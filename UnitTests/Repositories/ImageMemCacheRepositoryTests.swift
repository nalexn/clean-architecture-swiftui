//
//  ImageCacheRepositoryTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 10.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import Combine
@testable import CountriesSwiftUI

final class ImageMemCacheRepositoryTests: XCTestCase {
    
    private var sut: ImageMemCacheRepository!
    private var subscriptions = Set<AnyCancellable>()
    
    override func setUp() {
        subscriptions = Set<AnyCancellable>()
        sut = ImageMemCacheRepository()
    }
    
    func test_cachedImage_imageIsMissing() {
        let exp = XCTestExpectation(description: "Completion")
        sut.cachedImage(for: "missing_file").sinkToResult { result in
            XCTAssertTrue(Thread.isMainThread)
            result.assertFailure(ImageCacheError.imageIsMissing.localizedDescription)
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_cacheImage_cachedImage() {
        let image = UIColor.red.image(CGSize(width: 50, height: 50))
        let key = "image_key"
        sut.cache(image: image, key: key)
        let exp = XCTestExpectation(description: "Completion")
        sut.cachedImage(for: key).sinkToResult { result in
            XCTAssertTrue(Thread.isMainThread)
            result.assertSuccess(value: image)
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_purgeCache() {
        let image = UIColor.red.image(CGSize(width: 50, height: 50))
        let key = "image_key"
        sut.cache(image: image, key: key)
        sut.purgeCache()
        let exp = XCTestExpectation(description: "Completion")
        sut.cachedImage(for: key).sinkToResult { result in
            result.assertFailure(ImageCacheError.imageIsMissing.localizedDescription)
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
}
