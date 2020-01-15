//
//  SVGImageViewTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 10.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import CountriesSwiftUI

extension SVGImageView: Inspectable { }

final class SVGImageViewTests: XCTestCase {

    let url = URL(string: "https://test.com/test.png")!

    func test_imageView_notRequested() {
        let interactors = DIContainer.Interactors.mocked(
            imagesInteractor: [.loadImage(url)])
        let exp = XCTestExpectation(description: "onAppear")
        var sut = SVGImageView(imageURL: url, image: .notRequested)
        sut.didAppear = { view in
            view.inspect { content in
                XCTAssertNoThrow(try content.anyView().text())
            }
            interactors.asyncVerify(exp)
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_imageView_isLoading_initial() {
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        var sut = SVGImageView(imageURL: url, image: .isLoading(last: nil))
        sut.didAppear = { view in
            view.inspect { content in
                XCTAssertNoThrow(try content.anyView().view(ActivityIndicatorView.self))
            }
            interactors.asyncVerify(exp)
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_imageView_isLoading_refresh() {
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let image = UIColor.red.image(CGSize(width: 10, height: 10))
        var sut = SVGImageView(imageURL: url, image: .isLoading(last: image))
        sut.didAppear = { view in
            view.inspect { content in
                XCTAssertNoThrow(try content.anyView().view(ActivityIndicatorView.self))
            }
            interactors.asyncVerify(exp)
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_imageView_loaded() {
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        let image = UIColor.red.image(CGSize(width: 10, height: 10))
        var sut = SVGImageView(imageURL: url, image: .loaded(image))
        sut.didAppear = { view in
            view.inspect { content in
                let loadedImage = try content.anyView().image().uiImage()
                XCTAssertEqual(loadedImage, image)
            }
            interactors.asyncVerify(exp)
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 3)
    }
    
    func test_imageView_failed() {
        let interactors = DIContainer.Interactors.mocked()
        let exp = XCTestExpectation(description: "onAppear")
        var sut = SVGImageView(imageURL: url, image: .failed(NSError.test))
        sut.didAppear = { view in
            view.inspect { content in
                let message = try content.anyView().text().string()
                XCTAssertEqual(message, "Unable to load image")
            }
            interactors.asyncVerify(exp)
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
}
