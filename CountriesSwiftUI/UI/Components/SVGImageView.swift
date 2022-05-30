//
//  SVGImageView.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 25.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI
import Combine
import SVGView

struct SVGImageView: View {
    
    let imageURL: URL
    @Environment(\.injected) var injected: DIContainer
    @State private var image: Loadable<Data>
    let inspection = Inspection<Self>()
    
    init(imageURL: URL, image: Loadable<Data> = .notRequested) {
        self.imageURL = imageURL
        self._image = .init(initialValue: image)
    }
    
    var body: some View {
        content
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
    
    @ViewBuilder private var content: some View {
        switch image {
        case .notRequested:
            notRequestedView
        case .isLoading:
            loadingView
        case let .loaded(image):
            loadedView(image)
        case let .failed(error):
            failedView(error)
        }
    }
}

// MARK: - Side Effects

private extension SVGImageView {
    func loadImage() {
        injected.interactors.imagesInteractor
            .load(image: $image, url: imageURL)
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
    
    func loadedView(_ image: Data) -> some View {
        SVGView(data: image)
            .scaleEffect(0.2, anchor: .topLeading)
            .frame(width: 200, height: 140, alignment: .center)
    }
}

#if DEBUG
struct SVGImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SVGImageView(imageURL: URL(string: "https://flagcdn.com/us.svg")!)
            SVGImageView(imageURL: URL(string: "https://flagcdn.com/al.svg")!)
            SVGImageView(imageURL: URL(string: "https://flagcdn.com/ru.svg")!)
        }
    }
}
#endif
