//
//  ContentView.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @State private var otherViews: [StackItem] = ContentView.otherViews.value
    private let injector: DIContainer.Injector
    internal var isRunningTests: Bool = ProcessInfo.processInfo.isRunningTests
    
    init(injector: DIContainer.Injector) {
        self.injector = injector
    }
    
    var body: some View {
        ZStack {
            if isRunningTests {
                EmptyView()
                ForEach(otherViews) { $0.view }
                    .onReceive(ContentView.otherViews) { self.otherViews = $0 }
            } else {
                realContent
                    .modifier(injector)
            }
        }
    }
    
    private var realContent: some View {
        CountriesList()
            .modifier(RootViewAppearance())
    }
}

private extension ProcessInfo {
    var isRunningTests: Bool {
        environment["XCTestConfigurationFilePath"] != nil
    }
}

// MARK: - Adding Views to the hierarchy in tests

private extension ContentView {
    struct StackItem: Identifiable {
        let id: String
        let view: AnyView
    }
    static let otherViews: CurrentValueSubject<[StackItem], Never> = .init([])
}

#if DEBUG
extension ContentView {
    static func mount<V>(view: V, appState: AppState,
                         interactors: DIContainer.Interactors,
                         viewId: String = #function) where V: View {
        let appearance = RootViewAppearance()
        let injector = DIContainer.Injector(container: DIContainer(
            appState: .init(appState), interactors: interactors))
        let preparedView = view.modifier(appearance).modifier(injector)
        let item = StackItem(id: viewId, view: AnyView(preparedView))
        otherViews.value += [item]
    }
    
    static func unmount(viewId: String = #function) {
        var views = otherViews.value
        if let index = views.firstIndex(where: { $0.id == viewId }) {
            views.remove(at: index)
        }
        otherViews.value = views
    }
}
#endif

// MARK: - Preview

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(injector: .preview)
    }
}
#endif
