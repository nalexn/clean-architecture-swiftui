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
    case isLoading(last: T?, cancelBag: CancelBag)
    case loaded(T)
    case failed(Error)

    var value: T? {
        switch self {
        case let .loaded(value): return value
        case let .isLoading(last, _): return last
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
    
    mutating func cancelLoading() {
        switch self {
        case let .isLoading(last, cancelBag):
            cancelBag.cancel()
            if let last = last {
                self = .loaded(last)
            } else {
                let error = NSError(
                    domain: NSCocoaErrorDomain, code: NSUserCancelledError,
                    userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Canceled by user",
                                                                            comment: "")])
                self = .failed(error)
            }
        default: break
        }
    }
    
    func map<V>(_ transform: (T) -> V) -> Loadable<V> {
        switch self {
        case .notRequested: return .notRequested
        case let .failed(error): return .failed(error)
        case let .isLoading(value, cancelBag): return .isLoading(last: value.map { transform($0) },
                                                                 cancelBag: cancelBag)
        case let .loaded(value): return .loaded(transform(value))
        }
    }
}

extension Loadable: Equatable where T: Equatable {
    static func == (lhs: Loadable<T>, rhs: Loadable<T>) -> Bool {
        switch (lhs, rhs) {
        case (.notRequested, .notRequested): return true
        case let (.isLoading(lhsV, _), .isLoading(rhsV, _)): return lhsV == rhsV
        case let (.loaded(lhsV), .loaded(rhsV)): return lhsV == rhsV
        case let (.failed(lhsE), .failed(rhsE)):
            return lhsE.localizedDescription == rhsE.localizedDescription
        default: return false
        }
    }
}
