//
//  PushTokenWebRepository.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 26.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import Foundation

protocol PushTokenWebRepository: WebRepository {
    func register(devicePushToken: Data) async throws
}

struct RealPushTokenWebRepository: PushTokenWebRepository {
    
    let session: URLSession
    let baseURL: String
    
    init(session: URLSession) {
        self.session = session
        self.baseURL = "https://your-server.com/api/push-token"
    }
    
    func register(devicePushToken: Data) async throws {
        // upload the push token to your server
        // you can as well call a third party library here instead
    }
}
