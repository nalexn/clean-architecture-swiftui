//
//  ImageWebRepositoryTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 09.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import Combine
@testable import CountriesSwiftUI

final class ImageWebRepositoryTests: XCTestCase {

    private var sut: RealImageWebRepository!
    private var subscriptions = Set<AnyCancellable>()
    private lazy var testImage = UIColor.red.image(CGSize(width: 40, height: 40))
    private let svgToPngURL = "https://s1.ezgif.com/svg-to-png/ezgif-1-1d73ae275f02.svg?ajax=true"
    private let pngURL = "https://im2.ezgif.com/tmp/ezgif-2-91963ddbaa7a.png"
    
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        subscriptions = Set<AnyCancellable>()
        sut = RealImageWebRepository(session: .mockedResponsesOnly,
                                     baseURL: "https://test.com")
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    func test_loadImage_withConversion() throws {
        let bundle = Bundle(for: Self.self)
        let imageURL = try XCTUnwrap(URL(string: "https://image.service.com/myimage.svg"))
        let requestURL1 = try XCTUnwrap(URL(string: sut.baseURL + "/svg-to-png?url=" + imageURL.absoluteString))
        let requestURL2 = try XCTUnwrap(URL(string: svgToPngURL))
        let requestURL3 = try XCTUnwrap(URL(string: pngURL))
        let responseFile1 = try XCTUnwrap(bundle.url(forResource: "svg_convert_01", withExtension: "html"))
        let responseFile2 = try XCTUnwrap(bundle.url(forResource: "svg_convert_02", withExtension: "html"))
        let responseData1 = try XCTUnwrap(try? Data(contentsOf: responseFile1))
        let responseData2 = try XCTUnwrap(try? Data(contentsOf: responseFile2))
        let responseData3 = try XCTUnwrap(testImage.pngData())
        
        let mocks = [Mock(url: requestURL1, result: .success(responseData1)),
                     Mock(url: requestURL2, result: .success(responseData2)),
                     Mock(url: requestURL3, result: .success(responseData3))]
        mocks.forEach { RequestMocking.add(mock: $0) }
        
        let exp = XCTestExpectation(description: "Completion")
        sut.load(imageURL: imageURL, width: 300).sinkToResult { result in
            switch result {
            case let .success(resultValue):
                XCTAssertEqual(resultValue.size, self.testImage.size)
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_loadImage_withoutConversion() throws {
        
        let imageURL = try XCTUnwrap(URL(string: "https://image.service.com/myimage.png"))
        let responseData = try XCTUnwrap(testImage.pngData())
        let mock = Mock(url: imageURL, result: .success(responseData))
        RequestMocking.add(mock: mock)
        
        let exp = XCTestExpectation(description: "Completion")
        sut.load(imageURL: imageURL, width: 300).sinkToResult { result in
            switch result {
            case let .success(resultValue):
                XCTAssertEqual(resultValue.size, self.testImage.size)
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_loadImage_firstRequestFailure() throws {
        let imageURL = try XCTUnwrap(URL(string: "https://image.service.com/myimage.svg"))
        let requestURL1 = try XCTUnwrap(URL(string: sut.baseURL + "/svg-to-png?url=" + imageURL.absoluteString))
        let fakeData = "fakeData".data(using: .utf8)!
        let mocks = [Mock(url: requestURL1, result: .success(fakeData))]
        mocks.forEach { RequestMocking.add(mock: $0) }
        
        let exp = XCTestExpectation(description: "Completion")
        sut.load(imageURL: imageURL, width: 300).sinkToResult { result in
            result.assertFailure(APIError.imageProcessing([]).localizedDescription)
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_loadImage_secondRequestFailure() throws {
        let bundle = Bundle(for: Self.self)
        let imageURL = try XCTUnwrap(URL(string: "https://image.service.com/myimage.svg"))
        let requestURL1 = try XCTUnwrap(URL(string: sut.baseURL + "/svg-to-png?url=" + imageURL.absoluteString))
        let requestURL2 = try XCTUnwrap(URL(string: svgToPngURL))
        let responseFile1 = try XCTUnwrap(bundle.url(forResource: "svg_convert_01", withExtension: "html"))
        let responseData1 = try XCTUnwrap(try? Data(contentsOf: responseFile1))
        let fakeData = "fakeData".data(using: .utf8)!
        let mocks = [Mock(url: requestURL1, result: .success(responseData1)),
                     Mock(url: requestURL2, result: .success(fakeData))]
        mocks.forEach { RequestMocking.add(mock: $0) }
        
        let exp = XCTestExpectation(description: "Completion")
        sut.load(imageURL: imageURL, width: 300).sinkToResult { result in
            result.assertFailure(APIError.imageProcessing([]).localizedDescription)
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_loadImage_thirdRequestFailure() throws {
        let bundle = Bundle(for: Self.self)
        let imageURL = try XCTUnwrap(URL(string: "https://image.service.com/myimage.svg"))
        let requestURL1 = try XCTUnwrap(URL(string: sut.baseURL + "/svg-to-png?url=" + imageURL.absoluteString))
        let requestURL2 = try XCTUnwrap(URL(string: svgToPngURL))
        let requestURL3 = try XCTUnwrap(URL(string: pngURL))
        let responseFile1 = try XCTUnwrap(bundle.url(forResource: "svg_convert_01", withExtension: "html"))
        let responseFile2 = try XCTUnwrap(bundle.url(forResource: "svg_convert_02", withExtension: "html"))
        let responseData1 = try XCTUnwrap(try? Data(contentsOf: responseFile1))
        let responseData2 = try XCTUnwrap(try? Data(contentsOf: responseFile2))
        let responseData3 = try XCTUnwrap("fakeData".data(using: .utf8))
        
        let mocks = [Mock(url: requestURL1, result: .success(responseData1)),
                     Mock(url: requestURL2, result: .success(responseData2)),
                     Mock(url: requestURL3, result: .success(responseData3))]
        mocks.forEach { RequestMocking.add(mock: $0) }
        
        let exp = XCTestExpectation(description: "Completion")
        sut.load(imageURL: imageURL, width: 300).sinkToResult { result in
            result.assertFailure(APIError.imageProcessing([]).localizedDescription)
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_loadImage_malformedURL() throws {
        let malformedResponse = """
        <form class="form ajax-form" action="https<>.svg">
        <input type="hidden" value="db82d45c4085be" name="token">
        """
        let imageURL = try XCTUnwrap(URL(string: "https://image.service.com/myimage.svg"))
        let requestURL1 = try XCTUnwrap(URL(string: sut.baseURL + "/svg-to-png?url=" + imageURL.absoluteString))
        let responseData1 = try XCTUnwrap(malformedResponse.data(using: .utf8))
        let mocks = [Mock(url: requestURL1, result: .success(responseData1))]
        mocks.forEach { RequestMocking.add(mock: $0) }
        
        let exp = XCTestExpectation(description: "Completion")
        sut.load(imageURL: imageURL, width: 300).sinkToResult { result in
            result.assertFailure(APIError.imageProcessing([]).localizedDescription)
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
}
