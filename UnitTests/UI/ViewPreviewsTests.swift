//
//  ViewPreviewsTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 01.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
@testable import CountriesSwiftUI

class ViewPreviewsTests: XCTestCase {

    func test_contentView_previews() {
        _ = ContentView_Previews.previews
    }
    
    func test_countriesList_previews() {
        _ = CountriesList_Previews.previews
    }
    
    func test_countryDetails_previews() {
        _ = CountryDetails_Previews.previews
    }
    
    func test_modalDetailsView_previews() {
        _ = ModalDetailsView_Previews.previews
    }
    
    func test_countryCell_previews() {
        _ = CountryCell_Previews.previews
    }
    
    func test_detailRow_previews() {
        _ = DetailRow_Previews.previews
    }
    
    func test_errorView_previews() {
        _ = ErrorView_Previews.previews
    }
    
    func test_svgImageView_previews() {
        _ = SVGImageView_Previews.previews
    }
}
