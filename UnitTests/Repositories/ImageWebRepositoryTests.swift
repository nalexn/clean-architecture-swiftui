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
    private let testImage = Data()
    
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        subscriptions = Set<AnyCancellable>()
        sut = RealImageWebRepository(session: .mockedResponsesOnly,
                                     baseURL: "https://test.com")
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    func test_loadImage_success() throws {
        
        let imageURL = try XCTUnwrap(URL(string: "https://image.service.com/myimage.png"))
        let responseData = testImage
        let mock = Mock(url: imageURL, result: .success(responseData))
        RequestMocking.add(mock: mock)
        
        let exp = XCTestExpectation(description: "Completion")
        sut.load(imageURL: imageURL).sinkToResult { result in
            switch result {
            case let .success(resultValue):
                XCTAssertEqual(resultValue, self.testImage)
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_loadImage_failure() throws {
        let imageURL = try XCTUnwrap(URL(string: "https://image.service.com/myimage.png"))
        let mocks = [Mock(url: imageURL, result: .failure(APIError.unexpectedResponse))]
        mocks.forEach { RequestMocking.add(mock: $0) }
        
        let exp = XCTestExpectation(description: "Completion")
        sut.load(imageURL: imageURL).sinkToResult { result in
            result.assertFailure(APIError.unexpectedResponse.localizedDescription)
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
}
