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
    
    private let environment: RootViewModifier
    
    init(environment: RootViewModifier) {
        self.environment = environment
        #if DEBUG
        if !isRunningTests {
            RootViewInjection.mount(view: realContent, environment: environment)
        }
        #endif
    }
    
    var body: some View {
        #if DEBUG
        return root.view
        #else
        return realContent.modifier(environment)
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
    static var previews: some View {
        ContentView(environment:
            RootViewModifier(appState: AppState.preview,
                             interactors: InteractorsContainer.defaultValue))
    }
}
#endif
