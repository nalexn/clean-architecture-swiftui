//
//  SVGImageViewTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 10.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
@testable import CountriesSwiftUI

class SVGImageViewTests: XCTestCase {

    let url = URL(string: "https://test.com/test.png")!

    func test_imageView_notRequested() {
        let interactors = DIContainer.Interactors.mocked(
            imagesInteractor: [.loadImage(url)])
        let exp = XCTestExpectation(description: "onAppear")
        let sut = SVGImageView(imageURL: url, image: .notRequested)
            .asyncOnAppear {
                interactors.verify()
                ContentView.unmount()
                exp.fulfill()
            }
        ContentView.mount(view: sut, appState: AppState(), interactors: interactors)
        wait(for: [exp], timeout: 2)
    }
    
    func test_imageView_isLoading_initial() {
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let sut = SVGImageView(imageURL: url, image: .isLoading(last: nil))
            .asyncOnAppear {
                interactors.verify()
                ContentView.unmount()
                exp.fulfill()
            }
        ContentView.mount(view: sut, appState: AppState(), interactors: interactors)
        wait(for: [exp], timeout: 2)
    }
    
    func test_imageView_isLoading_refresh() {
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let image = UIColor.red.image(CGSize(width: 10, height: 10))
        let sut = SVGImageView(imageURL: url, image: .isLoading(last: image))
            .asyncOnAppear {
                interactors.verify()
                ContentView.unmount()
                exp.fulfill()
            }
        ContentView.mount(view: sut, appState: AppState(), interactors: interactors)
        wait(for: [exp], timeout: 2)
    }
    
    func test_imageView_loaded() {
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let image = UIColor.red.image(CGSize(width: 10, height: 10))
        let sut = SVGImageView(imageURL: url, image: .loaded(image))
            .asyncOnAppear {
                interactors.verify()
                ContentView.unmount()
                exp.fulfill()
            }
        ContentView.mount(view: sut, appState: AppState(), interactors: interactors)
        wait(for: [exp], timeout: 3)
    }
    
    func test_imageView_failed() {
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let sut = SVGImageView(imageURL: url, image: .failed(NSError.test))
            .asyncOnAppear {
                interactors.verify()
                ContentView.unmount()
                exp.fulfill()
            }
        ContentView.mount(view: sut, appState: AppState(), interactors: interactors)
        wait(for: [exp], timeout: 2)
    }
}
