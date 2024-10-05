//
//  ImagesService.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 09.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

protocol ImagesService {
    func load(image: LoadableSubject<UIImage>, url: URL?)
}

struct RealImagesService: ImagesService {
    
    let webRepository: ImageWebRepository
    
    init(webRepository: ImageWebRepository) {
        self.webRepository = webRepository
    }
    
    func load(image: LoadableSubject<UIImage>, url: URL?) {
        guard let url = url else {
            image.wrappedValue = .notRequested; return
        }
        let cancelBag = CancelBag()
        image.wrappedValue = .isLoading(last: image.wrappedValue.value, cancelBag: cancelBag)
        webRepository.load(imageURL: url)
            .sinkToLoadable {
                image.wrappedValue = $0
            }
            .store(in: cancelBag)
    }
}

struct StubImagesService: ImagesService {
    func load(image: LoadableSubject<UIImage>, url: URL?) {
    }
}
