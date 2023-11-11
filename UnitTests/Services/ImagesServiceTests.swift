//
//  ImagesServiceTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 10.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import Combine
@testable import CountriesSwiftUI

final class ImagesServiceTests: XCTestCase {
    
    var sut: RealImagesService!
    var mockedWebRepository: MockedImageWebRepository!
    var subscriptions = Set<AnyCancellable>()
    let testImageURL = URL(string: "https://test.com/test.png")!
    let testImage = UIColor.red.image(CGSize(width: 40, height: 40))
    
    override func setUp() {
        mockedWebRepository = MockedImageWebRepository()
        sut = RealImagesService(webRepository: mockedWebRepository)
        subscriptions = Set<AnyCancellable>()
    }
    
    func expectRepoActions(_ actions: [MockedImageWebRepository.Action]) {
        mockedWebRepository.actions = .init(expected: actions)
    }
    
    func verifyRepoActions(file: StaticString = #file, line: UInt = #line) {
        mockedWebRepository.verify(file: file, line: line)
    }
    
    func test_loadImage_nilURL() {
        let image = BindingWithPublisher(value: Loadable<UIImage>.notRequested)
        expectRepoActions([])
        sut.load(image: image.binding, url: nil)
        let exp = XCTestExpectation(description: "Completion")
        image.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .notRequested
            ])
            self.verifyRepoActions()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadImage_loadedFromWeb() {
        let image = BindingWithPublisher(value: Loadable<UIImage>.notRequested)
        mockedWebRepository.imageResponse = .success(testImage)
        expectRepoActions([.loadImage(testImageURL)])
        sut.load(image: image.binding, url: testImageURL)
        let exp = XCTestExpectation(description: "Completion")
        image.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: .test),
                .loaded(self.testImage)
            ])
            self.verifyRepoActions()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadImage_failed() {
        let image = BindingWithPublisher(value: Loadable<UIImage>.notRequested)
        let error = NSError.test
        mockedWebRepository.imageResponse = .failure(error)
        expectRepoActions([.loadImage(testImageURL)])
        sut.load(image: image.binding, url: testImageURL)
        let exp = XCTestExpectation(description: "Completion")
        image.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: .test),
                .failed(error)
            ])
            self.verifyRepoActions()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadImage_hadLoadedImage() {
        let image = BindingWithPublisher(value: Loadable<UIImage>.loaded(testImage))
        let error = NSError.test
        mockedWebRepository.imageResponse = .failure(error)
        expectRepoActions([.loadImage(testImageURL)])
        sut.load(image: image.binding, url: testImageURL)
        let exp = XCTestExpectation(description: "Completion")
        image.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .loaded(self.testImage),
                .isLoading(last: self.testImage, cancelBag: .test),
                .failed(error)
            ])
            self.verifyRepoActions()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 1)
    }
    
    func test_stubService() {
        let sut = StubImagesService()
        let image = BindingWithPublisher(value: Loadable<UIImage>.notRequested)
        sut.load(image: image.binding, url: testImageURL)
    }
}
