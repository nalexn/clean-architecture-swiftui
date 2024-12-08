//
//  LocaleReader.swift
//  CountriesSwiftUI
//
//  Created by Alexey on 8/11/24.
//  Copyright © 2024 Alexey Naumov. All rights reserved.
//

import SwiftUI

extension CountriesList {

    struct LocaleReader: EnvironmentalModifier {

        /**
         Retains the locale, provided by the Environment.
         Variable `@Environment(\.locale) var locale: Locale`
         from the view is not accessible when searching by name
         */
        final class Container {
            var locale: Locale = .backendDefault
        }
        let container: Container

        func resolve(in environment: EnvironmentValues) -> some ViewModifier {
            container.locale = environment.locale
            return DummyViewModifier()
        }

        private struct DummyViewModifier: ViewModifier {
            func body(content: Content) -> some View {
                // Cannot return just `content` because SwiftUI
                // flattens modifiers that do nothing to the `content`
                content.onAppear()
            }
        }
    }
}
