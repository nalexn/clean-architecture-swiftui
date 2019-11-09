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

class ImagesInteractorTests: XCTestCase {
    
    var sut: RealImagesInteractor!
    var appState: AppState!
    var mockedWebRepository: MockedImageWebRepository!
    var mockedInMemoryCache: MockedInMemoryImageCacheRepository!
    let memoryWanring = PassthroughSubject<Void, Never>()
    var subscriptions = Set<AnyCancellable>()
    let testImageURL = URL(string: "https://test.com/test.png")!
    let testImage = UIColor.red.image(CGSize(width: 40, height: 40))
    
    override func setUp() {
        appState = AppState()
        mockedWebRepository = MockedImageWebRepository()
        mockedInMemoryCache = MockedInMemoryImageCacheRepository()
        sut = RealImagesInteractor(webRepository: mockedWebRepository,
                                   inMemoryCacheRepository: mockedInMemoryCache,
                                   memoryWarning: memoryWanring.eraseToAnyPublisher(),
                                   appState: appState)
        subscriptions = Set<AnyCancellable>()
    }
    
    func test_loadImage_nilURL() {
        let image = BindingWithPublisher(value: Loadable<UIImage>.notRequested)
        sut.load(image: image.binding, url: nil)
        let exp = XCTestExpectation(description: "Completion")
        image.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .notRequested
            ])
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadImage_cachedInMemory() {
        let image = BindingWithPublisher(value: Loadable<UIImage>.notRequested)
        mockedInMemoryCache.imageResponse = .success(testImage)
        mockedWebRepository.imageResponse = .failure(APIError.unexpectedResponse)
        sut.load(image: image.binding, url: testImageURL)
        let exp = XCTestExpectation(description: "Completion")
        image.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil),
                .loaded(self.testImage)
            ])
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadImage_loadedFromWeb() {
        let image = BindingWithPublisher(value: Loadable<UIImage>.notRequested)
        mockedInMemoryCache.imageResponse = .failure(.imageIsMissing)
        mockedWebRepository.imageResponse = .success(testImage)
        sut.load(image: image.binding, url: testImageURL)
        let exp = XCTestExpectation(description: "Completion")
        image.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil),
                .loaded(self.testImage)
            ])
            let cachedImage = self.mockedInMemoryCache.cached[self.testImageURL.imageCacheKey]
            XCTAssertEqual(cachedImage, self.testImage)
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadImage_failed() {
        let image = BindingWithPublisher(value: Loadable<UIImage>.notRequested)
        let error = APIError.httpCode(500)
        mockedInMemoryCache.imageResponse = .failure(.imageIsMissing)
        mockedWebRepository.imageResponse = .failure(error)
        sut.load(image: image.binding, url: testImageURL)
        let exp = XCTestExpectation(description: "Completion")
        image.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil),
                .failed(error)
            ])
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadImage_hadLoadedImage() {
        let image = BindingWithPublisher(value: Loadable<UIImage>.loaded(testImage))
        let error = APIError.httpCode(500)
        mockedInMemoryCache.imageResponse = .failure(.imageIsMissing)
        mockedWebRepository.imageResponse = .failure(error)
        sut.load(image: image.binding, url: testImageURL)
        let exp = XCTestExpectation(description: "Completion")
        image.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .loaded(self.testImage),
                .isLoading(last: self.testImage),
                .failed(error)
            ])
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_imageCachePurge() {
        XCTAssertFalse(mockedInMemoryCache.didCallPurgeCache)
        memoryWanring.send(())
        XCTAssertTrue(mockedInMemoryCache.didCallPurgeCache)
    }
    
    func test_stubInteractor() {
        let sut = StubImagesInteractor()
        let image = BindingWithPublisher(value: Loadable<UIImage>.notRequested)
        sut.load(image: image.binding, url: testImageURL)
    }
}
