//
//  Publisher+WeakAssign.swift
//  CountriesSwiftUI
//
//  Created by Amadeu Cavalcante on 01/08/21.
//  Copyright © 2021 Alexey Naumov. All rights reserved.
//

import Foundation
import Combine

extension Publisher where Failure == Never {
    func weakAssign<T: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<T, Output>,
        on object: T
    ) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
}
