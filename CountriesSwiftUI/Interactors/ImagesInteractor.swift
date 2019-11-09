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
    let appState: AppState
    
    init(webRepository: ImageWebRepository, appState: AppState) {
        self.webRepository = webRepository
        self.appState = appState
    }
    
    func load(image: Binding<Loadable<UIImage>>, url: URL?) {
        guard let url = url else {
            image.wrappedValue = .notRequested; return
        }
        image.wrappedValue = .isLoading(last: image.wrappedValue.value)
        weak var weakAppState = appState
        let token = webRepository.load(imageURL: url, width: 300)
            .sinkToLoadable {
                image.wrappedValue = $0
                weakAppState?.system.runningRequests[url] = nil
            }
        appState.system.runningRequests[url] = token
    }
}

struct StubImagesInteractor: ImagesInteractor {
    func load(image: Binding<Loadable<UIImage>>, url: URL?) {
    }
}
