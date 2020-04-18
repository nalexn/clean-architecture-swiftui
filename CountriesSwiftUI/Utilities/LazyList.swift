//
//  LazyList.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 18.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import Foundation

struct LazyList<T> {
    
    typealias Access = (Int) throws -> T?
    private let access: Access
    private let useCache: Bool
    private var cache = Cache()
    
    let count: Int
    
    init(count: Int, useCache: Bool, _ access: @escaping Access) {
        self.count = count
        self.useCache = useCache
        self.access = access
    }
    
    func element(at index: Int) throws -> T {
        if useCache, let element = cache[index] {
            return element
        }
        guard let element = try access(index) else {
            throw Error.elementIsNil(index: index)
        }
        if useCache {
            cache[index] = element
        }
        return element
    }
    
    static var empty: Self {
        return .init(count: 0, useCache: false) { index in
            throw Error.elementIsNil(index: index)
        }
    }
}

private extension LazyList {
    class Cache {
        
        private var elements = [Int: T]()
        
        subscript(index: Int) -> T? {
            get {
                sync {
                    $0[index]
                }
            }
            set {
                sync {
                    $0[index] = newValue
                }
            }
        }
        
        private func sync<V>(_ access: (inout [Int: T]) -> V?) -> V? {
            if Thread.isMainThread {
                return access(&elements)
            } else {
                var result: V?
                DispatchQueue.main.sync {
                    result = access(&elements)
                }
                return result
            }
        }
    }
}

extension LazyList: Sequence {
    
    enum Error: LocalizedError {
        case elementIsNil(index: Int)
        
        var localizedDescription: String {
            switch self {
            case let .elementIsNil(index):
                return "Element at index \(index) is nil"
            }
        }
    }
    
    struct Iterator: IteratorProtocol {
        typealias Element = T
        private var index = -1
        private var list: LazyList<Element>
        
        init(list: LazyList<Element>) {
            self.list = list
        }
        
        mutating func next() -> Element? {
            index += 1
            do {
                return try list.element(at: index)
            } catch _ {
                return nil
            }
        }
    }

    func makeIterator() -> Iterator {
        .init(list: self)
    }

    var underestimatedCount: Int { count }
}

extension LazyList: RandomAccessCollection {
    
    typealias Index = Int
    var startIndex: Index { 0 }
    var endIndex: Index { count }
    
    subscript(index: Index) -> Iterator.Element {
        do {
            return try element(at: index)
        } catch let error {
            fatalError("\(error)")
        }
    }

    public func index(after index: Index) -> Index {
        return index + 1
    }

    public func index(before index: Index) -> Index {
        return index - 1
    }
}

extension LazyList: Equatable where T: Equatable {
    static func == (lhs: LazyList<T>, rhs: LazyList<T>) -> Bool {
        guard lhs.count == rhs.count else { return false }
        return zip(lhs, rhs).first(where: { $0 != $1 }) == nil
    }
}

extension LazyList: CustomStringConvertible {
    var description: String {
        let elements = self.reduce("", { str, element in
            if str.count == 0 {
                return "\(element)"
            }
            return str + ", \(element)"
        })
        return "LazyList<[\(elements)]>"
    }
}

extension RandomAccessCollection {
    var lazyList: LazyList<Element> {
        return .init(count: self.count, useCache: false) {
            guard $0 < self.count else { return nil }
            let index = self.index(self.startIndex, offsetBy: $0)
            return self[index]
        }
    }
}
