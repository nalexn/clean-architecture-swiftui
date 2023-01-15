import XCTest
import ViewInspector
@testable import CountriesSwiftUI

final class ContentViewTests: XCTestCase {

    func test_content_for_tests() throws {
        let viewModel = ContentView.ViewModel(container: .defaultValue, isRunningTests: true)
        let sut = ContentView(viewModel: viewModel)
        XCTAssertNoThrow(try sut.inspect().group().text(0))
    }
    
    func test_content_for_build() throws {
        let viewModel = ContentView.ViewModel(container: .defaultValue, isRunningTests: false)
        let sut = ContentView(viewModel: viewModel)
        XCTAssertNoThrow(try sut.inspect().group().view(CountriesList.self, 0))
    }
    
    func test_change_handler_for_colorScheme() throws {
        var appState = AppState()
        appState.routing.countriesList = .init(countryDetails: "USA")
        let container = DIContainer(appState: .init(appState), services: .mocked())
        let viewModel = ContentView.ViewModel(container: container)
        let sut = ContentView(viewModel: viewModel)
        sut.viewModel.onChangeHandler(.colorScheme)
        XCTAssertEqual(container.appState.value, appState)
        container.services.verify()
    }
    
    func test_change_handler_for_sizeCategory() throws {
        var appState = AppState()
        appState.routing.countriesList = .init(countryDetails: "USA")
        let container = DIContainer(appState: .init(appState), services: .mocked())
        let viewModel = ContentView.ViewModel(container: container)
        let sut = ContentView(viewModel: viewModel)
        XCTAssertEqual(container.appState.value, appState)
        sut.viewModel.onChangeHandler(.sizeCategory)
        XCTAssertEqual(container.appState.value, AppState())
        container.services.verify()
    }
}
