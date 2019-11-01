//
//  SVGImageViewTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 01.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import SwiftUI
@testable import CountriesSwiftUI

class SVGImageViewTests: XCTestCase {
    
    private lazy var url: URL = {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "svg_document", ofType: "svg")!
        return URL(fileURLWithPath: path)
    }()

    func test_svgImageLoading() {
        let exp = XCTestExpectation(description: "onAppear")
        let sut = SVGImageViewTest(imageURL: url)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.verifyScrollViewState(sut.wrapper.webView.scrollView)
            RootViewInjection.unmount()
            exp.fulfill()
        }
        RootViewInjection.mount(view: sut, environment: RootViewModifier(appState: AppState()))
        wait(for: [exp], timeout: 2.5)
    }
    
    private func verifyScrollViewState(_ scrollView: UIScrollView, file: StaticString = #file, line: UInt = #line) {
        let scale = scrollView.transform.scale
        XCTAssertEqual(scale.x, scale.y, "Scale factors along X and Y must match", file: file, line: line)
        let contentSize = CGSize(width: 900, height: 600)
        let scaledContentSize = CGSize(width: contentSize.width * scale.x, height: contentSize.height * scale.y)
        let boundsSize = scrollView.frame.size
        XCTAssertGreaterThanOrEqual(boundsSize.width, scaledContentSize.width,
                                 "Scaled content should not go beyond view's bounds", file: file, line: line)
        XCTAssertGreaterThanOrEqual(boundsSize.height, scaledContentSize.height,
        "Scaled content should not go beyond view's bounds", file: file, line: line)
        let offset = scrollView.contentOffset
        XCTAssertLessThanOrEqual(abs(offset.x + 0.5 * (boundsSize.width / scale.x - contentSize.width)), 0.5,
                                 "Offset should center the content in the view", file: file, line: line)
        XCTAssertLessThanOrEqual(abs(offset.y + 0.5 * (boundsSize.height / scale.y - contentSize.height)), 0.5,
        "Offset should center the content in the view", file: file, line: line)
    }
}

private struct SVGImageViewTest: View {
    let imageURL: URL
    let wrapper: SVGImageView.Wrapper
    
    init(imageURL: URL) {
        self.imageURL = imageURL
        wrapper = SVGImageView.Wrapper(imageURL: imageURL)
    }
    
    var body: some View {
        wrapper
    }
}

private extension CGAffineTransform {
    var scale: CGPoint {
        CGPoint(x: sqrt(a * a + c * c),
                y: sqrt(b * b + d * d))
    }
}
