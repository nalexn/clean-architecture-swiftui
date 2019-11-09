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

struct RealImageWebRepository {
    
    let session: URLSession
    let baseURL: String
    let bgQueue = DispatchQueue(label: "bg_parse_queue")
    
    init(session: URLSession, baseURL: String) {
        self.session = session
        self.baseURL = baseURL
    }
    
    func load(imageURL: URL, width: Int) -> AnyPublisher<UIImage, Error> {
        if (imageURL.absoluteString as NSString).pathExtension.lowercased() == "svg" {
            return importImage(originalURL: imageURL)
                .flatMap { self.exportImage(info: $0, width: width) }
                .flatMap { self.download(rawImageURL: $0.imageURL) }
                .eraseToAnyPublisher()
        } else {
            return download(rawImageURL: imageURL)
        }
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
            .subscribe(on: bgQueue)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

private struct ImageConversion { }

extension ImageConversion {
    struct Import {
        
        let urlString: String
        let ajaxToken: String
        
        init(data: Data?) throws {
            guard let data = data, let string = String(data: data, encoding: .utf8)
                else { throw APIError.unexpectedResponse }
            guard let elementWithURL = string.firstMatch(pattern: #"<form class="form ajax-form".*>"#),
                let conversionURL = elementWithURL.firstMatch(pattern: #"https.*\.svg"#)
                else { throw APIError.unexpectedResponse }
            guard let ajaxTokenElement = string.firstMatch(pattern: #"<input .*name=\"token\".*>"#),
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
            guard let data = data, let string = String(data: data, encoding: .utf8)
                else { throw APIError.unexpectedResponse }
            guard let element = string.firstMatch(pattern: #"src=.*style="width"#),
                let imageURL = element.firstMatch(pattern: #"\/\/.*\.png"#)
                else { throw APIError.unexpectedResponse }
            guard let url = URL(string: "https:" + imageURL)
                else { throw APIError.unexpectedResponse }
            self.imageURL = url
        }
    }
}

private extension String {
    func firstMatch(pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
            let matchResult = regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count))
            else { return nil }
        for index in 0 ..< matchResult.numberOfRanges {
            if matchResult.range(at: index).location != NSNotFound {
                return (self as NSString).substring(with: matchResult.range(at: index))
            }
        }
        return nil
    }
}

// MARK: - Endpoints

extension RealImageWebRepository {
    enum API: APICall {
        case prepareConversion(URL)
        var path: String {
            switch self {
            case let .prepareConversion(url):
                return "/svg-to-png?url=" + url.absoluteString
            }
        }
        var method: String { "GET" }
        var headers: [String: String]? { nil }
        func body() throws -> Data? { nil }
    }
}
