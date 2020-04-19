//
//  CoreDataHelpers.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 12.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import CoreData
import Combine

// MARK: - ManagedEntity

protocol ManagedEntity: NSFetchRequestResult { }

extension ManagedEntity where Self: NSManagedObject {
    
    static var entityName: String {
        let nameMO = String(describing: Self.self)
        let suffixIndex = nameMO.index(nameMO.endIndex, offsetBy: -2)
        return String(nameMO[..<suffixIndex])
    }
    
    static func insertNew(in context: NSManagedObjectContext) -> Self? {
        return NSEntityDescription
            .insertNewObject(forEntityName: entityName, into: context) as? Self
    }
    
    static func newFetchRequest() -> NSFetchRequest<Self> {
        return .init(entityName: entityName)
    }
}

// MARK: - NSManagedObjectContext

extension NSManagedObjectContext {
    
    func configureAsReadOnlyContext() {
        automaticallyMergesChangesFromParent = true
        mergePolicy = NSRollbackMergePolicy
        undoManager = nil
        shouldDeleteInaccessibleFaults = true
    }
    
    func configureAsUpdateContext() {
        mergePolicy = NSOverwriteMergePolicy
        undoManager = nil
    }
}

// MARK: - Misc

extension NSSet {
    func toArray<T>(of type: T.Type) -> [T] {
        allObjects.compactMap { $0 as? T }
    }
}
