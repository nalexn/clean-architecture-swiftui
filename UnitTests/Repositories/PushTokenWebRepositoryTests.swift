//
//  PushTokenWebRepositoryTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 26.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import Testing
import Foundation
@testable import CountriesSwiftUI

@Suite struct PushTokenWebRepositoryTests {

    private let sut = RealPushTokenWebRepository(session: .mockedResponsesOnly)

    @Test func register() async throws {
        try await sut.register(devicePushToken: Data())
    }
}

