//
//  ImageView.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 25.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI
import Combine

struct ImageView: View {
    
    let imageURL: URL
    @Environment(\.injected) var injected: DIContainer
    @State private var image: Loadable<UIImage>
    let inspection = Inspection<Self>()
    
    init(imageURL: URL, image: Loadable<UIImage> = .notRequested) {
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

private extension ImageView {
    func loadImage() {
        injected.interactors.imagesInteractor
            .load(image: $image, url: imageURL)
    }
}

// MARK: - Content

private extension ImageView {
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
    
    func loadedView(_ uiImage: UIImage) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

#if DEBUG
struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ImageView(imageURL: URL(string: "https://flagcdn.com/w640/us.jpg")!)
            ImageView(imageURL: URL(string: "https://flagcdn.com/w640/al.jpg")!)
            ImageView(imageURL: URL(string: "https://flagcdn.com/w640/ru.jpg")!)
        }
    }
}
#endif
