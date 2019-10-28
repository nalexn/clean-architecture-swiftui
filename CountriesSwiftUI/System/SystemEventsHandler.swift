//
//  SystemEventsHandler.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 27.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import UIKit

protocol SystemEventsHandlerProtocol {
    func sceneOpenURLContexts(_ urlContexts: Set<UIOpenURLContext>)
    func sceneDidBecomeActive()
    func sceneWillResignActive()
}

struct SystemEventsHandler: SystemEventsHandlerProtocol {
    
    let appState: AppState
    
    func sceneOpenURLContexts(_ urlContexts: Set<UIOpenURLContext>) {
        
    }
    
    func sceneDidBecomeActive() {
        appState.system.isActive = true
    }
    
    func sceneWillResignActive() {
        appState.system.isActive = false
    }
}
