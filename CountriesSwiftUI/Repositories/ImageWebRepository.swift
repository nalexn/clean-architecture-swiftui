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
        return importImage(originalURL: imageURL)
            .flatMap { self.exportImage(info: $0, width: width) }
            .flatMap { self.download(rawImageURL: $0.imageURL) }
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
            .tryMap { try ImageConversion.Import(data: $0.data) }
            .eraseToAnyPublisher()
    }
    
    private func exportImage(info: ImageConversion.Import, width: Int) -> AnyPublisher<ImageConversion.Export, Error> {
        guard let conversionURL = URL(string: info.urlString + "?ajax=true") else {
            return Fail<ImageConversion.Export, Error>(
                error: APIError.unexpectedResponse).eraseToAnyPublisher()
        }
        var convertRequest = URLRequest(url: conversionURL)
        convertRequest.httpMethod = "POST"
        let body: [String: Any] = [
            "file": (info.urlString as NSString).lastPathComponent,
            "token": info.ajaxToken,
            "width": width
        ]
        let bodyString = body.map { $0.key + "=" + "\($0.value)" }.joined(separator: "&")
        convertRequest.httpBody = bodyString.data(using: .utf8)
        return session.dataTaskPublisher(for: convertRequest)
            .tryMap { try ImageConversion.Export(data: $0.data) }
            .eraseToAnyPublisher()
    }
    
    private func download(rawImageURL: URL) -> AnyPublisher<UIImage, Error> {
        return session.dataTaskPublisher(for: URLRequest(url: rawImageURL))
            .tryMap { (data, response) in
                guard let image = UIImage(data: data)
                    else { throw APIError.unexpectedResponse }
                return image
            }
            .eraseToAnyPublisher()
    }
}

private struct ImageConversion { }

extension ImageConversion {
    struct Import {
        
        let urlString: String
        let ajaxToken: String
        
        init(data: Data?) throws {
            guard let data = data, let string = String(data: data, encoding: .utf8),
                let elementWithURL = string.firstMatch(pattern: #"<form class="form ajax-form".*\.svg">"#),
                let conversionURL = elementWithURL.firstMatch(pattern: #"https.*\.svg"#),
                let ajaxTokenElement = string.firstMatch(pattern: #"name=\"file\"><input .*name=\"token\".*>"#),
                let dirtyToken = ajaxTokenElement.firstMatch(pattern: #"value="([a-z]|[0-9])*"#)
                else { throw APIError.unexpectedResponse }
            self.urlString = conversionURL
            self.ajaxToken = String(dirtyToken.suffix(from: dirtyToken.index(dirtyToken.startIndex, offsetBy: 7)))
        }
    }
}

extension ImageConversion {
    struct Export {
        
        let imageURL: URL

        init(data: Data?) throws {
            guard let data = data, let string = String(data: data, encoding: .utf8),
                let element = string.firstMatch(pattern: #"src=.*style="width"#),
                let imageURL = element.firstMatch(pattern: #"\/\/.*\.png"#),
                let url = URL(string: "https:" + imageURL)
                else { throw APIError.unexpectedResponse }
            self.imageURL = url
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
