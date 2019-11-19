//
//  ImageFileCacheRepository.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 10.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import UIKit
import Foundation
import Combine

extension ImageFileCacheRepository {
    static let defaultFileExpiration: TimeInterval = 8 * 60 * 60 // 8 hours
    static var defaultCachesURL: URL? {
        return FileManager().urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("images", isDirectory: true)
    }
}

struct ImageFileCacheRepository: ImageCacheRepository {
    
    private let fileExpiration: TimeInterval
    private let fileManager = FileManager()
    private let cachesURL: URL?
    private let bgQueue = DispatchQueue(label: "file_io_queue")

    init(fileExpiration: TimeInterval = defaultFileExpiration,
         cachesURL: URL? = ImageFileCacheRepository.defaultCachesURL) {
        self.fileExpiration = fileExpiration
        self.cachesURL = cachesURL
    }

    func cache(image: UIImage, key: ImageCacheKey) {
        guard let url = fileManager.fileURL(cachesURL: cachesURL, key: key),
            !fileManager.fileExists(atPath: url.path),
            let data = image.pngData() else { return }
        bgQueue.async {
            self.fileManager.createDirectoryIfNeeded(url: self.cachesURL)
            try? data.write(to: url, options: [])
        }
    }

    func cachedImage(for key: ImageCacheKey) -> AnyPublisher<UIImage, ImageCacheError> {
        return Future<UIImage, ImageCacheError>({ promise in
            self.bgQueue.async {
                let url = self.fileManager.fileURL(cachesURL: self.cachesURL, key: key)
                if let url = url,
                    let fileDate = self.fileManager.fileModificationDate(fileURL: url),
                    fileDate.timestamp + self.fileExpiration > Date().timestamp,
                    let data = try? Data(contentsOf: url),
                    let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        promise(.success(image))
                    }
                } else {
                    self.removeItem(url: url)
                    DispatchQueue.main.async {
                        promise(.failure(.imageIsMissing))
                    }
                }
            }
        })
        .eraseToAnyPublisher()
    }
    
    func purgeCache() {
        removeItem(url: cachesURL)
    }
    
    private func removeItem(url: URL?) {
        guard let url = url else { return }
        bgQueue.async {
            try? self.fileManager.removeItem(at: url)
        }
    }
}

// MARK: - Helpers

private extension FileManager {
    func createDirectoryIfNeeded(url: URL?) {
        guard let url = url else { return }
        if !fileExists(atPath: url.path) {
            try? createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func fileURL(cachesURL: URL?, key: ImageCacheKey) -> URL? {
        let fileName = key.description
            .components(separatedBy: .init(charactersIn: "\\/:?%*|\"'<>")).joined()
        return cachesURL?.appendingPathComponent(fileName)
    }
    
    func fileModificationDate(fileURL: URL) -> Date? {
        return try? attributesOfItem(atPath: fileURL.path)[.creationDate] as? Date
    }
}

private extension Date {
    var timestamp: TimeInterval { timeIntervalSinceReferenceDate }
}
