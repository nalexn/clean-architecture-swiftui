//
//  RootViewInjection.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 01.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI

#if DEBUG

/// `RootViewInjection` is used for adding views onto the view hierarchy during testing.
/// Disabled for production
class RootViewInjection: ObservableObject {
    
    @Published private(set) var view = AnyView(EmptyView())
    
    private var views: [StackItem] = []
    private init() {
        reloadView()
    }
    
    static func mount<V>(view: V, injector: DependencyInjector, viewId: String = #function) where V: View {
        let root = shared
        let appearance = RootViewAppearance(appState: injector.appState)
        let preparedView = view.modifier(injector).modifier(appearance)
        root.views.append(StackItem(id: viewId, view: AnyView(preparedView)))
        root.reloadView()
    }
    
    static func unmount(viewId: String = #function) {
        let root = shared
        if let index = root.views.firstIndex(where: { $0.id == viewId }) {
            root.views.remove(at: index)
        }
        root.reloadView()
    }
    
    private func reloadView() {
        view = viewStack
    }
    
    private var viewStack: AnyView {
        if views.count > 0 {
            return AnyView(ZStack {
                        ForEach(views) { $0.view }
                   })
        } else {
            return AnyView(EmptyView())
        }
    }
}

private extension RootViewInjection {
    struct StackItem: Identifiable {
        let id: String
        let view: AnyView
    }
}

extension RootViewInjection {
    static var shared = RootViewInjection()
}

#endif
