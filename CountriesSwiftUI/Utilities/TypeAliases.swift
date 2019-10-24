//
//  Helpers.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Combine
import Foundation

typealias ValueClosure<V> = (V) -> Void
typealias Property<T> = AnyPublisher<T, Never>
typealias Resource<T> = CurrentValueSubject<Loadable<T>, Never>
