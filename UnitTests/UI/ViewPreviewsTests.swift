//
//  ViewPreviewsTests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 01.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import XCTest
import ViewInspector
@testable import CountriesSwiftUI

final class ViewPreviewsTests: XCTestCase {

    @MainActor
    func test_contentView_previews() {
        _ = ContentView_Previews.previews
    }
    
    @MainActor
    func test_countriesList_previews() {
        _ = CountriesList_Previews.previews
    }
    
    @MainActor
    func test_countryDetails_previews() {
        _ = CountryDetails_Previews.previews
    }
    
    @MainActor
    func test_modalDetailsView_previews() {
        _ = ModalDetailsView_Previews.previews
    }
    
    @MainActor
    func test_countryCell_previews() {
        _ = CountryCell_Previews.previews
    }
    
    @MainActor
    func test_detailRow_previews() {
        _ = DetailRow_Previews.previews
    }
    
    @MainActor
    func test_errorView_previews() throws {
        let view = ErrorView_Previews.previews
        try view.inspect().implicitAnyView().view(ErrorView.self).actualView().retryAction()
    }
    
    @MainActor
    func test_imageView_previews() {
        _ = ImageView_Previews.previews
    }
}
