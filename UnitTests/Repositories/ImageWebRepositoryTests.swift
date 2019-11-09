//
//  ImageWebRepositoryTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 09.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import Foundation
@testable import CountriesSwiftUI

class ImageWebRepositoryTests: XCTestCase {

    var sut: RealImageWebRepository!
    private lazy var testImage = UIColor.red.image(CGSize(width: 40, height: 40))
    
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        sut = RealImageWebRepository(session: .mockedResponsesOnly,
                                     baseURL: "https://test.com")
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    func test_loadImage_withConversion() {
        let bundle = Bundle(for: Self.self)
        guard let imageURL = URL(string: "https://image.service.com/myimage.svg"),
            let requestURL1 = URL(string: sut.baseURL + "/svg-to-png?url=" + imageURL.absoluteString),
            let requestURL2 = URL(string: "https://s2.ezgif.com/svg-to-png/ezgif-2-046afd16dc45.svg?ajax=true"),
            let requestURL3 = URL(string: "https://im2.ezgif.com/tmp/ezgif-2-91963ddbaa7a.png"),
            let responseFile1 = bundle.url(forResource: "svg_convert_01", withExtension: "html"),
            let responseFile2 = bundle.url(forResource: "svg_convert_02", withExtension: "html"),
            let responseData1 = try? Data(contentsOf: responseFile1),
            let responseData2 = try? Data(contentsOf: responseFile2),
            let responseData3 = testImage.pngData()
            else { XCTFail(); return }
        
        let mocks = [Mock(url: requestURL1, result: .success(responseData1)),
                     Mock(url: requestURL2, result: .success(responseData2)),
                     Mock(url: requestURL3, result: .success(responseData3))]
        mocks.forEach { RequestMocking.add(mock: $0) }
        
        let exp = XCTestExpectation(description: "Completion")
        _ = sut.load(imageURL: imageURL, width: 300).sinkResult { result in
            switch result {
            case let .success(resultValue):
                XCTAssertEqual(resultValue.size, self.testImage.size)
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2)
    }
    
    func test_loadImage_withoutConversion() {
        guard let imageURL = URL(string: "https://image.service.com/myimage.png"),
            let responseData = testImage.pngData()
            else { XCTFail(); return }
        
        let mock = Mock(url: imageURL, result: .success(responseData))
        RequestMocking.add(mock: mock)
        
        let exp = XCTestExpectation(description: "Completion")
        _ = sut.load(imageURL: imageURL, width: 300).sinkResult { result in
            switch result {
            case let .success(resultValue):
                XCTAssertEqual(resultValue.size, self.testImage.size)
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2)
    }
    
    func test_loadImage_firstRequestFailure() {
        guard let imageURL = URL(string: "https://image.service.com/myimage.svg"),
            let requestURL1 = URL(string: sut.baseURL + "/svg-to-png?url=" + imageURL.absoluteString)
            else { XCTFail(); return }
        let fakeData = "fakeData".data(using: .utf8)!
        let mocks = [Mock(url: requestURL1, result: .success(fakeData))]
        mocks.forEach { RequestMocking.add(mock: $0) }
        
        let exp = XCTestExpectation(description: "Completion")
        _ = sut.load(imageURL: imageURL, width: 300).sinkResult { result in
            result.assertFailure(APIError.unexpectedResponse.localizedDescription)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2)
    }
    
    func test_loadImage_secondRequestFailure() {
        let bundle = Bundle(for: Self.self)
        guard let imageURL = URL(string: "https://image.service.com/myimage.svg"),
            let requestURL1 = URL(string: sut.baseURL + "/svg-to-png?url=" + imageURL.absoluteString),
            let requestURL2 = URL(string: "https://s2.ezgif.com/svg-to-png/ezgif-2-046afd16dc45.svg?ajax=true"),
            let responseFile1 = bundle.url(forResource: "svg_convert_01", withExtension: "html"),
            let responseData1 = try? Data(contentsOf: responseFile1)
            else { XCTFail(); return }
        let fakeData = "fakeData".data(using: .utf8)!
        let mocks = [Mock(url: requestURL1, result: .success(responseData1)),
                     Mock(url: requestURL2, result: .success(fakeData))]
        mocks.forEach { RequestMocking.add(mock: $0) }
        
        let exp = XCTestExpectation(description: "Completion")
        _ = sut.load(imageURL: imageURL, width: 300).sinkResult { result in
            result.assertFailure(APIError.unexpectedResponse.localizedDescription)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2)
    }
    
    func test_loadImage_thirdRequestFailure() {
        let bundle = Bundle(for: Self.self)
        guard let imageURL = URL(string: "https://image.service.com/myimage.svg"),
            let requestURL1 = URL(string: sut.baseURL + "/svg-to-png?url=" + imageURL.absoluteString),
            let requestURL2 = URL(string: "https://s2.ezgif.com/svg-to-png/ezgif-2-046afd16dc45.svg?ajax=true"),
            let requestURL3 = URL(string: "https://im2.ezgif.com/tmp/ezgif-2-91963ddbaa7a.png"),
            let responseFile1 = bundle.url(forResource: "svg_convert_01", withExtension: "html"),
            let responseFile2 = bundle.url(forResource: "svg_convert_02", withExtension: "html"),
            let responseData1 = try? Data(contentsOf: responseFile1),
            let responseData2 = try? Data(contentsOf: responseFile2),
            let responseData3 = "fakeData".data(using: .utf8)
            else { XCTFail(); return }
        
        let mocks = [Mock(url: requestURL1, result: .success(responseData1)),
                     Mock(url: requestURL2, result: .success(responseData2)),
                     Mock(url: requestURL3, result: .success(responseData3))]
        mocks.forEach { RequestMocking.add(mock: $0) }
        
        let exp = XCTestExpectation(description: "Completion")
        _ = sut.load(imageURL: imageURL, width: 300).sinkResult { result in
            result.assertFailure(APIError.unexpectedResponse.localizedDescription)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2)
    }
    
    func test_loadImage_malformedURL() {
        let malformedResponse = """
        <form class="form ajax-form" action="https<>.svg">
        <input type="hidden" value="db82d45c4085be" name="token">
        """
        guard let imageURL = URL(string: "https://image.service.com/myimage.svg"),
            let requestURL1 = URL(string: sut.baseURL + "/svg-to-png?url=" + imageURL.absoluteString),
            let responseData1 = malformedResponse.data(using: .utf8)
            else { XCTFail(); return }
        let mocks = [Mock(url: requestURL1, result: .success(responseData1))]
        mocks.forEach { RequestMocking.add(mock: $0) }
        
        let exp = XCTestExpectation(description: "Completion")
        _ = sut.load(imageURL: imageURL, width: 300).sinkResult { result in
            result.assertFailure(APIError.unexpectedResponse.localizedDescription)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2)
    }
}
