//
//  Deduplicated.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 17.12.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Foundation
import Combine

extension ObservableObject {
    
    func deduplicated<Snapshot>(_ snapshot: @escaping (Self) -> Snapshot)
        -> Deduplicated<Self, Snapshot> where Snapshot: Equatable {
        return .init(object: self, snapshot: snapshot)
    }
}

@dynamicMemberLookup
class Deduplicated<Object, Snapshot>: ObservableObject
    where Object: ObservableObject, Snapshot: Equatable {
    
    private(set) var original: Object
    private var subscription: AnyCancellable?
    @Published private var bootstrap: Bool = false
    
    fileprivate init(object: Object,
                     snapshot: @escaping (Object) -> Snapshot) {
        self.original = object
        let makeSnapshot: () -> Snapshot? = { [weak self] in
            guard let self = self else { return nil }
            return snapshot(self.original)
        }
        subscription = object.objectWillChange
            .delay(for: .nanoseconds(1), scheduler: RunLoop.main)
            .compactMap { _ in makeSnapshot() }
            .prepend(makeSnapshot())
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
    }
    
    subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Object, Subject>) -> Subject {
        get { original[keyPath: keyPath] }
        set { original[keyPath: keyPath] = newValue }
    }
}
