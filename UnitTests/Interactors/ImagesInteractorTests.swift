//
//  ImagesInteractorTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 10.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import Combine
@testable import CountriesSwiftUI

final class ImagesInteractorTests: XCTestCase {
    
    var sut: RealImagesInteractor!
    var mockedWebRepository: MockedImageWebRepository!
    var mockedInMemoryCache: MockedImageCacheRepository!
    var mockedFileCache: MockedImageCacheRepository!
    let memoryWanring = PassthroughSubject<Void, Never>()
    var subscriptions = Set<AnyCancellable>()
    let testImageURL = URL(string: "https://test.com/test.png")!
    let testImage = UIColor.red.image(CGSize(width: 40, height: 40))
    
    override func setUp() {
        mockedWebRepository = MockedImageWebRepository()
        mockedInMemoryCache = MockedImageCacheRepository()
        mockedFileCache = MockedImageCacheRepository()
        sut = RealImagesInteractor(webRepository: mockedWebRepository,
                                   inMemoryCache: mockedInMemoryCache,
                                   fileCache: mockedFileCache,
                                   memoryWarning: memoryWanring.eraseToAnyPublisher())
        subscriptions = Set<AnyCancellable>()
    }
    
    func expect(inMemory: [MockedImageWebRepository.Action],
                file: [MockedImageWebRepository.Action],
                web: [MockedImageWebRepository.Action]) {
        mockedInMemoryCache.actions = .init(expected: inMemory)
        mockedFileCache.actions = .init(expected: file)
        mockedWebRepository.actions = .init(expected: web)
    }
    
    func verifyRepos(file: StaticString = #file, line: UInt = #line) {
        mockedInMemoryCache.verify(file: file, line: line)
        mockedFileCache.verify(file: file, line: line)
        mockedWebRepository.verify(file: file, line: line)
    }
    
    func test_loadImage_nilURL() {
        let image = BindingWithPublisher(value: Loadable<UIImage>.notRequested)
        expect(inMemory: [],
               file: [],
               web: [])
        sut.load(image: image.binding, url: nil)
        let exp = XCTestExpectation(description: "Completion")
        image.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .notRequested
            ])
            self.verifyRepos()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadImage_cachedInMemory() {
        let image = BindingWithPublisher(value: Loadable<UIImage>.notRequested)
        mockedInMemoryCache.imageResponse = .success(testImage)
        mockedFileCache.imageResponse = .failure(.imageIsMissing)
        mockedWebRepository.imageResponse = .failure(APIError.unexpectedResponse)
        expect(inMemory: [.loadImage(testImageURL)],
               file: [],
               web: [])
        sut.load(image: image.binding, url: testImageURL)
        let exp = XCTestExpectation(description: "Completion")
        image.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(self.testImage)
            ])
            self.verifyRepos()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadImage_cachedOnDisk() {
        let image = BindingWithPublisher(value: Loadable<UIImage>.notRequested)
        mockedInMemoryCache.imageResponse = .failure(.imageIsMissing)
        mockedFileCache.imageResponse = .success(testImage)
        mockedWebRepository.imageResponse = .failure(APIError.unexpectedResponse)
        expect(inMemory: [.loadImage(testImageURL)],
               file: [.loadImage(testImageURL)],
               web: [])
        sut.load(image: image.binding, url: testImageURL)
        let exp = XCTestExpectation(description: "Completion")
        image.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(self.testImage)
            ])
            let cachedImage = self.mockedInMemoryCache.cached[self.testImageURL.imageCacheKey]
            XCTAssertEqual(cachedImage, self.testImage)
            self.verifyRepos()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadImage_loadedFromWeb() {
        let image = BindingWithPublisher(value: Loadable<UIImage>.notRequested)
        mockedInMemoryCache.imageResponse = .failure(.imageIsMissing)
        mockedFileCache.imageResponse = .failure(.imageIsMissing)
        mockedWebRepository.imageResponse = .success(testImage)
        expect(inMemory: [.loadImage(testImageURL)],
               file: [.loadImage(testImageURL)],
               web: [.loadImage(testImageURL)])
        sut.load(image: image.binding, url: testImageURL)
        let exp = XCTestExpectation(description: "Completion")
        image.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(self.testImage)
            ])
            let cachedImage = self.mockedInMemoryCache.cached[self.testImageURL.imageCacheKey]
            XCTAssertEqual(cachedImage, self.testImage)
            self.verifyRepos()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadImage_failed() {
        let image = BindingWithPublisher(value: Loadable<UIImage>.notRequested)
        let error = NSError.test
        mockedInMemoryCache.imageResponse = .failure(.imageIsMissing)
        mockedFileCache.imageResponse = .failure(.imageIsMissing)
        mockedWebRepository.imageResponse = .failure(error)
        expect(inMemory: [.loadImage(testImageURL)],
               file: [.loadImage(testImageURL)],
               web: [.loadImage(testImageURL)])
        sut.load(image: image.binding, url: testImageURL)
        let exp = XCTestExpectation(description: "Completion")
        image.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .failed(error)
            ])
            self.verifyRepos()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadImage_hadLoadedImage() {
        let image = BindingWithPublisher(value: Loadable<UIImage>.loaded(testImage))
        let error = NSError.test
        mockedInMemoryCache.imageResponse = .failure(.imageIsMissing)
        mockedFileCache.imageResponse = .failure(.imageIsMissing)
        mockedWebRepository.imageResponse = .failure(error)
        expect(inMemory: [.loadImage(testImageURL)],
               file: [.loadImage(testImageURL)],
               web: [.loadImage(testImageURL)])
        sut.load(image: image.binding, url: testImageURL)
        let exp = XCTestExpectation(description: "Completion")
        image.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .loaded(self.testImage),
                .isLoading(last: self.testImage, cancelBag: CancelBag()),
                .failed(error)
            ])
            self.verifyRepos()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_imageCachePurge() {
        expect(inMemory: [], file: [], web: [])
        XCTAssertFalse(mockedInMemoryCache.didCallPurgeCache)
        memoryWanring.send(())
        XCTAssertTrue(mockedInMemoryCache.didCallPurgeCache)
        verifyRepos()
    }
    
    func test_stubInteractor() {
        let sut = StubImagesInteractor()
        let image = BindingWithPublisher(value: Loadable<UIImage>.notRequested)
        sut.load(image: image.binding, url: testImageURL)
    }
}
