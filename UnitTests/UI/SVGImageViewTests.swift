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
    
    func svgImageView(_ image: Loadable<UIImage>,
                      _ services: DIContainer.Services) -> SVGImageView {
        let container = DIContainer(appState: AppState(), services: services)
        let viewModel = SVGImageView.ViewModel(
            container: container, imageURL: url, image: image)
        return SVGImageView(viewModel: viewModel)
    }

    func test_imageView_notRequested() {
        let services = DIContainer.Services.mocked(
            imagesService: [.loadImage(url)])
        let sut = svgImageView(.notRequested, services)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(text: ""))
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_imageView_isLoading_initial() {
        let services = DIContainer.Services.mocked()
        let sut = svgImageView(.isLoading(last: nil, cancelBag: CancelBag()), services)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ActivityIndicatorView.self))
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_imageView_isLoading_refresh() {
        let services = DIContainer.Services.mocked()
        let image = UIColor.red.image(CGSize(width: 10, height: 10))
        let sut = svgImageView(.isLoading(last: image, cancelBag: CancelBag()), services)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(ActivityIndicatorView.self))
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_imageView_loaded() {
        let services = DIContainer.Services.mocked()
        let image = UIColor.red.image(CGSize(width: 10, height: 10))
        let sut = svgImageView(.loaded(image), services)
        let exp = sut.inspection.inspect { view in
            let loadedImage = try view.find(ViewType.Image.self).actualImage().uiImage()
            XCTAssertEqual(loadedImage, image)
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 3)
    }
    
    func test_imageView_failed() {
        let services = DIContainer.Services.mocked()
        let sut = svgImageView(.failed(NSError.test), services)
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(text: "Unable to load image"))
            services.verify()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
}
