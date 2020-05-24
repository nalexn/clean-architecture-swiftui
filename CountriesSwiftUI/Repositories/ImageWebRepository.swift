//
//  ImageWebRepository.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 09.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Combine
import UIKit

protocol ImageWebRepository: WebRepository {
    func load(imageURL: URL, width: Int) -> AnyPublisher<UIImage, Error>
}

struct RealImageWebRepository: ImageWebRepository {
    
    let session: URLSession
    let baseURL: String
    let bgQueue = DispatchQueue(label: "bg_parse_queue")
    
    init(session: URLSession, baseURL: String) {
        self.session = session
        self.baseURL = baseURL
    }
    
    func load(imageURL: URL, width: Int) -> AnyPublisher<UIImage, Error> {
        guard (imageURL.absoluteString as NSString).pathExtension.lowercased() == "svg" else {
            return download(rawImageURL: imageURL)
            .subscribe(on: bgQueue)
            .receive(on: DispatchQueue.main)
            .extractUnderlyingError()
            .eraseToAnyPublisher()
        }
        return Just<Void>.withErrorType(Error.self)
            .flatMap { self.importImage(originalURL: imageURL) }
            .flatMap { self.exportImage(imported: $0, width: width) }
            .flatMap { self.download(exported: $0) }
            .catch { self.removeCachedResponses(error: $0) }
            .subscribe(on: bgQueue)
            .receive(on: DispatchQueue.main)
            .extractUnderlyingError()
            .eraseToAnyPublisher()
    }
    
    private func importImage(originalURL: URL) -> AnyPublisher<ImageConversion.Import, Error> {
        guard let conversionURL = URL(string:
            baseURL + "/svg-to-png?url=" + originalURL.absoluteString) else {
            return Fail<ImageConversion.Import, Error>(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        var urlRequest = URLRequest(url: conversionURL)
        urlRequest.httpMethod = "GET"
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { try ImageConversion.Import(data: $0.data, urlRequest: urlRequest) }
            .eraseToAnyPublisher()
    }
    
    private func exportImage(imported: ImageConversion.Import,
                             width: Int) -> AnyPublisher<ImageConversion.Export, Error> {
        guard let conversionURL = URL(string: imported.urlString + "?ajax=true") else {
            return Fail<ImageConversion.Export, Error>(
                error: APIError.imageProcessing([imported.urlRequest]))
                .eraseToAnyPublisher()
        }
        var urlRequest = URLRequest(url: conversionURL)
        urlRequest.httpMethod = "POST"
        let body: [String: Any] = [
            "file": (imported.urlString as NSString).lastPathComponent,
            "token": imported.ajaxToken,
            "width": width
        ]
        let bodyString = body.map { $0.key + "=" + "\($0.value)" }.joined(separator: "&")
        urlRequest.httpBody = bodyString.data(using: .utf8)
        let urlRequests = [imported.urlRequest, urlRequest]
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { try ImageConversion.Export(data: $0.data, urlRequests: urlRequests) }
            .eraseToAnyPublisher()
    }
    
    private func download(exported: ImageConversion.Export) -> AnyPublisher<UIImage, Error> {
        download(rawImageURL: exported.imageURL, requests: exported.urlRequests)
    }
    
    private func download(rawImageURL: URL, requests: [URLRequest] = []) -> AnyPublisher<UIImage, Error> {
        let urlRequest = URLRequest(url: rawImageURL)
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { (data, response) in
                guard let image = UIImage(data: data)
                    else { throw APIError.imageProcessing(requests + [urlRequest]) }
                return image
            }
            .eraseToAnyPublisher()
    }
    
    private func removeCachedResponses(error: Error) -> AnyPublisher<UIImage, Error> {
        if let apiError = error as? APIError,
            case let .imageProcessing(urlRequests) = apiError,
            let cache = session.configuration.urlCache {
            urlRequests.forEach(cache.removeCachedResponse)
        }
        return Fail(error: error).eraseToAnyPublisher()
    }
}

private struct ImageConversion { }

extension ImageConversion {
    struct Import {
        
        let urlString: String
        let ajaxToken: String
        let urlRequest: URLRequest
        
        init(data: Data?, urlRequest: URLRequest) throws {
            guard let data = data, let string = String(data: data, encoding: .utf8),
                let elementWithURL = string.firstMatch(pattern: #"<form class="form ajax-form".*\.svg">"#),
                let conversionURL = elementWithURL.firstMatch(pattern: #"https.*\.svg"#),
                let ajaxTokenElement = string.firstMatch(pattern: #"name=\"file\"><input .*name=\"token\".*>"#),
                let dirtyToken = ajaxTokenElement.firstMatch(pattern: #"value="([a-z]|[0-9])*"#)
                else { throw APIError.imageProcessing([urlRequest]) }
            self.urlString = conversionURL
            self.ajaxToken = String(dirtyToken.suffix(from: dirtyToken.index(dirtyToken.startIndex, offsetBy: 7)))
            self.urlRequest = urlRequest
        }
    }
}

extension ImageConversion {
    struct Export {
        
        let imageURL: URL
        let urlRequests: [URLRequest]

        init(data: Data?, urlRequests: [URLRequest]) throws {
            guard let data = data, let string = String(data: data, encoding: .utf8),
                let element = string.firstMatch(pattern: #"src=.*style="width"#),
                let imageURL = element.firstMatch(pattern: #"\/\/.*\.png"#),
                let url = URL(string: "https:" + imageURL)
                else { throw APIError.imageProcessing(urlRequests) }
            self.imageURL = url
            self.urlRequests = urlRequests
        }
    }
}

private extension String {
    func firstMatch(pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
            let matchResult = regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)),
            let range = matchResult.ranges.first(where: { $0.location != NSNotFound })
            else { return nil }
        return (self as NSString).substring(with: range)
    }
}

extension NSTextCheckingResult {
    struct Iterator: IteratorProtocol {
        typealias Element = NSRange
        
        private var index: Int = 0
        private let collection: NSTextCheckingResult
        
        init(collection: NSTextCheckingResult) {
            self.collection = collection
        }
        
        mutating func next() -> NSRange? {
            defer { index += 1 }
            return index < collection.numberOfRanges ? collection.range(at: index) : nil
        }
    }
}

extension NSTextCheckingResult {
    var ranges: IteratorSequence<NSTextCheckingResult.Iterator> {
        return .init(.init(collection: self))
    }
}
