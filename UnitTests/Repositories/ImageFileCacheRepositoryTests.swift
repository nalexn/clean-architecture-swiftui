//
//  ImageFileCacheRepositoryTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 10.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
@testable import CountriesSwiftUI

class ImageFileCacheRepositoryTests: XCTestCase {

    var sut: ImageFileCacheRepository!
    let testCachesURL: URL = {
        FileManager().urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("tests", isDirectory: true)
    }()
    
    override func setUp() {
        try? FileManager().removeItem(at: testCachesURL)
        sut = ImageFileCacheRepository(fileExpiration: 5, cachesURL: testCachesURL)
    }
    
    func test_cachedImage_imageIsMissing() {
        let exp = XCTestExpectation(description: "Completion")
        _ = sut.cachedImage(for: "missing_file").sinkToResult { result in
            XCTAssertTrue(Thread.isMainThread)
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
        _ = sut.cachedImage(for: key).sinkToResult { result in
            XCTAssertTrue(Thread.isMainThread)
            switch result {
            case let .success(returnedImage):
                XCTAssertEqual(returnedImage.size, image.size)
            case let .failure(error):
                XCTFail("Unexpected error: \(error.localizedDescription)")
            }
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
        _ = sut.cachedImage(for: key).sinkToResult { result in
            result.assertFailure(ImageCacheError.imageIsMissing.localizedDescription)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_cacheExpiration() {
        sut = ImageFileCacheRepository(fileExpiration: 0.1, cachesURL: testCachesURL)
        let image = UIColor.red.image(CGSize(width: 50, height: 50))
        let key = "image_key"
        sut.cache(image: image, key: key)
        let exp = XCTestExpectation(description: "Completion")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            _ = self.sut.cachedImage(for: key).sinkToResult { result in
                result.assertFailure(ImageCacheError.imageIsMissing.localizedDescription)
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_cachesDefaultURL() {
        guard let cachesURL = ImageFileCacheRepository.defaultCachesURL
            else { XCTFail(); return }
        let fileManager = FileManager()
        let doesDirectoryExist = fileManager.fileExists(atPath: cachesURL.path)
        do {
            if !doesDirectoryExist {
                try fileManager.createDirectory(at: cachesURL, withIntermediateDirectories: true, attributes: nil)
            }
            let testFileURL = cachesURL.appendingPathComponent("test_image")
            let image = UIColor.red.image(CGSize(width: 1, height: 1))
            try image.pngData()?.write(to: testFileURL)
            XCTAssertTrue(fileManager.fileExists(atPath: testFileURL.path))
            try fileManager.removeItem(at: testFileURL)
            if !doesDirectoryExist {
                try fileManager.removeItem(at: cachesURL)
            }
        } catch let error {
            XCTFail("\(error)")
        }
    }
}
