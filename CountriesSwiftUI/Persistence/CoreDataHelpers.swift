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
        return entity().name ?? String(describing: Self.self)
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
    
    func configureAsMainContext() {
        automaticallyMergesChangesFromParent = true
        mergePolicy = NSRollbackMergePolicy
        undoManager = nil
        shouldDeleteInaccessibleFaults = true
    }
    
    func configureAsBackgroundUpdateContext() {
        mergePolicy = NSOverwriteMergePolicy
        undoManager = nil
    }
    
    func loadAsynchronously<T>(_ fetchRequest: NSFetchRequest<T>) -> Future<[T], Error> {
        return Future<[T], Error> { [weak self] promise in
            let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { result in
                promise(.success(result.finalResult ?? []))
            }
            do {
                try self?.execute(asyncRequest)
            } catch {
                promise(.failure(error))
            }
        }
    }
}

// MARK: - Misc

extension NSSet {
    func toArray<T>(of type: T.Type) -> [T] {
        allObjects.compactMap { $0 as? T }
    }
}
