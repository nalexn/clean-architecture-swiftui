import XCTest
import ViewInspector
@testable import CountriesSwiftUI

extension ContentView: Inspectable { }

final class ContentViewTests: XCTestCase {

    func test_content_for_tests() throws {
        let sut = ContentView(container: .defaultValue, isRunningTests: true)
        XCTAssertNoThrow(try sut.inspect().group().text(0))
    }
    
    func test_content_for_build() throws {
        let sut = ContentView(container: .defaultValue, isRunningTests: false)
        XCTAssertNoThrow(try sut.inspect().group().view(CountriesList.self, 0))
    }
    
    func test_change_handler_for_colorScheme() throws {
        var appState = AppState()
        appState.routing.countriesList = .init(countryDetails: "USA")
        let container = DIContainer(appState: .init(appState), interactors: .mocked())
        let sut = ContentView(container: container)
        sut.onChangeHandler(.colorScheme)
        XCTAssertEqual(container.appState.value, appState)
        container.interactors.verify()
    }
    
    func test_change_handler_for_sizeCategory() throws {
        var appState = AppState()
        appState.routing.countriesList = .init(countryDetails: "USA")
        let container = DIContainer(appState: .init(appState), interactors: .mocked())
        let sut = ContentView(container: container)
        XCTAssertEqual(container.appState.value, appState)
        sut.onChangeHandler(.sizeCategory)
        XCTAssertEqual(container.appState.value, AppState())
        container.interactors.verify()
    }
}
