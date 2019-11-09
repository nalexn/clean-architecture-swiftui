//
//  ContentView.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    #if DEBUG
    @ObservedObject private var root: RootViewInjection = .shared
    #endif
    
    private let injector: DependencyInjector
    private let appearance: RootViewAppearance
    
    init(injector: DependencyInjector) {
        self.injector = injector
        self.appearance = RootViewAppearance(appState: injector.appState)
        #if DEBUG
        if !isRunningTests {
            RootViewInjection.mount(view: realContent, injector: injector)
        }
        #endif
    }
    
    var body: some View {
        #if DEBUG
        return root.view
        #else
        return realContent
            .modifier(injector)
            .modifier(appearance)
        #endif
    }
    
    private var realContent: some View {
        CountriesList()
    }
    
    private var isRunningTests: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var dependencyInjector: DependencyInjector {
        DependencyInjector(appState: AppState.preview,
                           interactors: InteractorsContainer.defaultValue)
    }
    static var previews: some View {
        ContentView(injector: dependencyInjector)
    }
}
#endif
