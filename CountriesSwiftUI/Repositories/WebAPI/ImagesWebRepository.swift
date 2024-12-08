//
//  ImageWebRepository.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 09.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Combine
import UIKit

protocol ImagesWebRepository: WebRepository {
    func loadImage(url: URL) async throws -> UIImage
}

struct RealImagesWebRepository: ImagesWebRepository {

    let session: URLSession
    let baseURL: String
    
    init(session: URLSession) {
        self.session = session
        self.baseURL = ""
    }
    
    func loadImage(url: URL) async throws -> UIImage {
        let (localURL, _) = try await session.download(from: url)
        let data = try Data(contentsOf: localURL)
        guard let image = UIImage(data: data) else {
            throw APIError.imageDeserialization
        }
        return image
    }
}
