//
//  ContentViewTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 23.12.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
@testable import CountriesSwiftUI

class ContentViewTests: XCTestCase {

    func test_prodBody() {
        var sut = ContentView(container: .preview)
        sut.isRunningTests = false
        XCTAssertNoThrow(sut.body)
    }
}
