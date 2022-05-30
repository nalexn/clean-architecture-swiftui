//
//  SVGImageViewTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 10.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import SwiftUI
import SVGView
import ViewInspector
@testable import CountriesSwiftUI

extension SVGImageView: Inspectable { }
extension SVGView: Inspectable { }

final class SVGImageViewTests: XCTestCase {

    let url = URL(string: "https://test.com/test.png")!

    func test_imageView_notRequested() {
        let interactors = DIContainer.Interactors.mocked(
            imagesInteractor: [.loadImage(url)])
        let sut = SVGImageView(imageURL: url, image: .notRequested)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(text: ""))
            interactors.verify()
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_imageView_isLoading_initial() {
        let interactors = DIContainer.Interactors.mocked()
        let sut = SVGImageView(imageURL: url, image:
            .isLoading(last: nil, cancelBag: CancelBag()))
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ActivityIndicatorView.self))
            interactors.verify()
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_imageView_isLoading_refresh() {
        let interactors = DIContainer.Interactors.mocked()
        let sut = SVGImageView(imageURL: url, image:
            .isLoading(last: Data(), cancelBag: CancelBag()))
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ActivityIndicatorView.self))
            interactors.verify()
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
    
    func test_imageView_loaded() {
        let interactors = DIContainer.Interactors.mocked()
        let image = Data()
        let sut = SVGImageView(imageURL: url, image: .loaded(image))
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ViewType.View<SVGView>.self))
            interactors.verify()
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 3)
    }
    
    func test_imageView_failed() {
        let interactors = DIContainer.Interactors.mocked()
        let sut = SVGImageView(imageURL: url, image: .failed(NSError.test))
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(text: "Unable to load image"))
            interactors.verify()
        }
        ViewHosting.host(view: sut.inject(AppState(), interactors))
        wait(for: [exp], timeout: 2)
    }
}
