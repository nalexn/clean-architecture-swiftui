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
    
    @ObservedObject private(set) var viewModel: ViewModel
    let inspection = Inspection<Self>()
    
    var body: some View {
        content
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
    
    @ViewBuilder private var content: some View {
        switch viewModel.image {
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

private extension ImageView.ViewModel {
    func loadImage() {
        container.services.imagesService
            .load(image: loadableSubject(\.image), url: imageURL)
    }
}

// MARK: - Content

private extension ImageView {
    var notRequestedView: some View {
        Text("").onAppear {
            self.viewModel.loadImage()
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

// MARK: - ViewModel

extension ImageView {
    class ViewModel: ObservableObject {
        
        // State
        let imageURL: URL
        @Published var image: Loadable<UIImage>
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(container: DIContainer, imageURL: URL, image: Loadable<UIImage> = .notRequested) {
            self.imageURL = imageURL
            self._image = .init(initialValue: image)
            self.container = container
        }
    }
}

#if DEBUG
struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(viewModel: ImageView.ViewModel(
            container: .preview, imageURL: URL(string: "https://flagcdn.com/w640/us.jpg")!))
    }
}
#endif
