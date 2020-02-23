//
//  ImagesInteractor.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 09.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

protocol ImagesInteractor {
    func load(image: Binding<Loadable<UIImage>>, url: URL?)
}

struct RealImagesInteractor: ImagesInteractor {
    
    let webRepository: ImageWebRepository
    
    init(webRepository: ImageWebRepository) {
        self.webRepository = webRepository
    }
    
    func load(image: Binding<Loadable<UIImage>>, url: URL?) {
        guard let url = url else {
            image.wrappedValue = .notRequested; return
        }
        let cancelBag = CancelBag()
        image.wrappedValue = .isLoading(last: image.wrappedValue.value, cancelBag: cancelBag)
        webRepository.load(imageURL: url, width: 300)
            .sinkToLoadable {
                image.wrappedValue = $0
            }
            .store(in: cancelBag)
    }
}

struct StubImagesInteractor: ImagesInteractor {
    func load(image: Binding<Loadable<UIImage>>, url: URL?) {
    }
}
