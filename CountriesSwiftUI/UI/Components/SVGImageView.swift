//
//  SVGImageView.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 25.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI
import Combine
import WebKit

struct SVGImageView: View {
    
    let imageURL: URL
    @Environment(\.injected) var injected: DIContainer
    @State private var image: Loadable<UIImage>
    private let cancelBag = CancelBag()
    let inspection = Inspection<Self>()
    
    init(imageURL: URL, image: Loadable<UIImage> = .notRequested) {
        self.imageURL = imageURL
        self._image = .init(initialValue: image)
    }
    
    var body: some View {
        content
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
    
    private var content: AnyView {
        switch image {
        case .notRequested: return AnyView(notRequestedView)
        case .isLoading: return AnyView(loadingView)
        case let .loaded(image): return AnyView(loadedView(image))
        case let .failed(error): return AnyView(failedView(error))
        }
    }
}

// MARK: - Side Effects

private extension SVGImageView {
    func loadImage() {
        injected.interactors.imagesInteractor
            .load(image: $image, url: imageURL)
            .store(in: cancelBag)
    }
}

// MARK: - Content

private extension SVGImageView {
    var notRequestedView: some View {
        Text("").onAppear {
            self.loadImage()
        }
    }
    
    var loadingView: some View {
        ActivityIndicatorView()
    }
    
    func failedView(_ error: Error) -> some View {
        Text("Unable to load image")
            .font(.footnote)
            .multilineTextAlignment(.center)
            .padding()
    }
    
    func loadedView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

#if DEBUG
struct SVGImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SVGImageView(imageURL: URL(string: "https://restcountries.eu/data/usa.svg")!)
            SVGImageView(imageURL: URL(string: "https://restcountries.eu/data/alb.svg")!)
            SVGImageView(imageURL: URL(string: "https://restcountries.eu/data/rus.svg")!)
        }
    }
}
#endif
