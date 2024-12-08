//
//  ImageWebRepositoryTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 09.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Testing
import UIKit.UIImage
@testable import CountriesSwiftUI

@Suite(.serialized) final class ImageWebRepositoryTests {

    private let sut = RealImagesWebRepository(session: .mockedResponsesOnly)
    private let testImage = UIColor.red.image(CGSize(width: 40, height: 40))

    typealias Mock = RequestMocking.MockedResponse

    deinit {
        RequestMocking.removeAllMocks()
    }

    @Test func loadImageSuccess() async throws {
        let imageURL = try #require(URL(string: "https://image.service.com/myimage.png"))
        let imageRef = try #require(testImage.pngData())
        let mock = Mock(url: imageURL, result: .success(imageRef))
        RequestMocking.add(mock: mock)

        let result = try await sut.loadImage(url: imageURL)
        #expect(result.size == testImage.size)
    }

    @Test func loadImageFailure() async throws {
        let imageURL = try #require(URL(string: "https://image.service.com/myimage.png"))
        let errorRef = NSError.test
        let mock = Mock(url: imageURL, result: .failure(errorRef))
        RequestMocking.add(mock: mock)

        do {
            _ = try await sut.loadImage(url: imageURL)
            Issue.record("Above should throw")
        } catch {
            let nsError = error as NSError
            #expect(nsError.domain == errorRef.domain)
            #expect(nsError.code == errorRef.code)
        }
    }
}

