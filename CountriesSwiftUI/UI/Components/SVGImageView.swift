//
//  SVGImageView.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 25.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI
import WebKit

struct SVGImageView: View {
    let imageURL: URL
    
    var body: some View {
        Wrapper(imageURL: imageURL)
            .shadow(radius: 3)
    }
}

private extension SVGImageView {
    struct Wrapper: UIViewRepresentable {
        
        let imageURL: URL

        func makeUIView(context: UIViewRepresentableContext<SVGImageView.Wrapper>) -> WKWebView {
            let view = WKWebView()
            view.navigationDelegate = WebViewDelegate.shared
            view.isUserInteractionEnabled = false
            return view
        }

        func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<SVGImageView.Wrapper>) {
            let urlRequest = URLRequest(url: imageURL)
            uiView.load(urlRequest)
        }
        
        static func dismantleUIView(_ uiView: WKWebView, coordinator: ()) {
            uiView.navigationDelegate = nil
        }
    }
    
    class WebViewDelegate: NSObject, WKNavigationDelegate {
        
        static let shared = WebViewDelegate()
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.documentElement.getAttribute(\"width\")") { (widthValue, error) in
                guard let width = widthValue.floatValue else { return }
                webView.evaluateJavaScript("document.documentElement.getAttribute(\"height\")") { (heightValue, error) in
                    guard let height = heightValue.floatValue else { return }
                    webView.scaleToFit(contentSize: CGSize(width: width, height: height))
                }
            }
        }
    }
}

private extension WKWebView {
    func scaleToFit(contentSize: CGSize) {
        let webViewSize = bounds.size
        let hZoom = webViewSize.width / contentSize.width
        let vZoom = webViewSize.height / contentSize.height
        let zoom = min(hZoom, vZoom)
        scrollView.zoomScale = 1
        scrollView.transform = CGAffineTransform(scaleX: zoom, y: zoom)
        let offset = CGPoint(x: 0.5 * (contentSize.width - webViewSize.width / zoom),
                             y: 0.5 * (contentSize.height - webViewSize.height / zoom))
        scrollView.contentInset = UIEdgeInsets(top: -offset.y, left: -offset.x,
                                               bottom: -offset.y, right: -offset.x)
        scrollView.contentOffset = offset
    }
}

private extension Optional {
    var floatValue: CGFloat? {
        switch self {
        case let .some(value):
            if let intValue = Int(String(describing: value)) {
                return CGFloat(intValue)
            }
        default: break
        }
        return nil
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
