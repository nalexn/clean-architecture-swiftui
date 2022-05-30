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
    func load(imageURL: URL) -> AnyPublisher<Data, Error>
}

struct RealImageWebRepository: ImageWebRepository {
    
    let session: URLSession
    let baseURL: String
    let bgQueue = DispatchQueue(label: "bg_parse_queue")
    
    init(session: URLSession, baseURL: String) {
        self.session = session
        self.baseURL = baseURL
    }
    
    func load(imageURL: URL) -> AnyPublisher<Data, Error> {
        return download(rawImageURL: imageURL)
            .subscribe(on: bgQueue)
            .receive(on: DispatchQueue.main)
            .extractUnderlyingError()
            .eraseToAnyPublisher()
    }
    
    private func download(rawImageURL: URL) -> AnyPublisher<Data, Error> {
        let urlRequest = URLRequest(url: rawImageURL)
        return session.dataTaskPublisher(for: urlRequest)
            .requestData()
    }
}
