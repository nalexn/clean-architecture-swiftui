//
//  Loadable.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Foundation

enum Loadable<T> {

    case notRequested
    case isLoading(last: T?)
    case loaded(T)
    case failed(Error)

    var isNotRequested: Bool {
        switch self {
        case .notRequested: return true
        default: return false
        }
    }
    var isLoading: Bool {
        switch self {
        case .isLoading: return true
        default: return false
        }
    }
    var value: T? {
        switch self {
        case let .loaded(value): return value
        case let .isLoading(last): return last
        default: return nil
        }
    }
    var error: Error? {
        switch self {
        case let .failed(error): return error
        default: return nil
        }
    }
}

extension Loadable {
    func map<V>(_ transform: (T) -> (V)) -> Loadable<V> {
        switch self {
        case .notRequested: return .notRequested
        case let .failed(error): return .failed(error)
        case let .loaded(value): return .loaded(transform(value))
        case let .isLoading(value):
            if let value = value {
                return .isLoading(last: transform(value))
            } else {
                return .isLoading(last: nil)
            }
        }
    }
}

extension Loadable: Equatable where T: Equatable {
    static func == (lhs: Loadable<T>, rhs: Loadable<T>) -> Bool {
        switch (lhs, rhs) {
        case (.notRequested, .notRequested): return true
        case let (.isLoading(lhsV), .isLoading(rhsV)): return lhsV == rhsV
        case let (.loaded(lhsV), .loaded(rhsV)): return lhsV == rhsV
        case let (.failed(lhsE), .failed(rhsE)):
            return lhsE.localizedDescription == rhsE.localizedDescription
        default: return false
        }
    }
}
