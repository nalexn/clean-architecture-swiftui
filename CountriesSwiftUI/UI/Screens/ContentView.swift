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
    
    init(injector: DIContainer.Injector) {
        self.injector = injector
    }
    
    var body: some View {
        ZStack {
            if isRunningTests {
                EmptyView()
                ForEach(otherViews) { $0.view }
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
    
    private var isRunningTests: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}

extension ContentView {
    struct StackItem: Identifiable {
        let id: String
        let view: AnyView
    }
    static let otherViews: CurrentValueSubject<[StackItem], Never> = .init([])
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(injector: .preview)
    }
}
#endif
