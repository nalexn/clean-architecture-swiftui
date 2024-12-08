//
//  ImageViewTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 10.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Testing
import SwiftUI
import ViewInspector
@testable import CountriesSwiftUI

@MainActor
@Suite struct ImageViewTests {

    let url = URL(string: "https://test.com/test.png")!

    @Test func imageViewNotRequested() async throws {
        let container = DIContainer(interactors: .mocked(
            images: [.loadImage(url)]
        ))
        let sut = ImageView(imageURL: url, image: .notRequested)
        try await ViewHosting.host(sut.inject(container)) {
            try await sut.inspection.inspect { view in
                #expect(throws: Never.self) { try view.find(text: "") }
                container.interactors.verify()
            }
        }
    }
    
    @Test func imageViewIsLoadingInitial() async throws {
        let container = DIContainer(interactors: .mocked())
        let sut = ImageView(imageURL: url, image:
            .isLoading(last: nil, cancelBag: .test))
        try await ViewHosting.host(sut.inject(container)) {
            try await sut.inspection.inspect { view in
                #expect(throws: Never.self) { try view.find(ViewType.ProgressView.self) }
                container.interactors.verify()
            }
        }
    }
    
    @Test func imageViewIsLoadingRefresh() async throws {
        let container = DIContainer(interactors: .mocked())
        let image = UIColor.red.image(CGSize(width: 10, height: 10))
        let sut = ImageView(imageURL: url, image:
            .isLoading(last: image, cancelBag: .test))
        try await ViewHosting.host(sut.inject(container)) {
            try await sut.inspection.inspect { view in
                #expect(throws: Never.self) { try view.find(ViewType.ProgressView.self) }
                container.interactors.verify()
            }
        }
    }
    
    @Test func imageViewLoaded() async throws {
        let container = DIContainer(interactors: .mocked())
        let image = UIColor.red.image(CGSize(width: 10, height: 10))
        let sut = ImageView(imageURL: url, image: .loaded(image))
        try await ViewHosting.host(sut.inject(container)) {
            try await sut.inspection.inspect { view in
                let loadedImage = try view.find(ViewType.Image.self).actualImage().uiImage()
                #expect(loadedImage == image)
                container.interactors.verify()
            }
        }
    }
    
    @Test func imageViewFailed() async throws {
        let container = DIContainer(interactors: .mocked())
        let sut = ImageView(imageURL: url, image: .failed(NSError.test))
        try await ViewHosting.host(sut.inject(container)) {
            try await sut.inspection.inspect { view in
                #expect(throws: Never.self) { try view.find(text: "Unable to load image") }
                container.interactors.verify()
            }
        }
    }
}
