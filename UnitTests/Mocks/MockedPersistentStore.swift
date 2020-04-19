//
//  MockedPersistentStore.swift
//  UnitTests
//
//  Created by Alexey Naumov on 19.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import CoreData
import Combine
@testable import CountriesSwiftUI

final class MockedPersistentStore: Mock, PersistentStore {
    struct ContextSnapshot: Equatable {
        let inserted: Int
        let updated: Int
        let deleted: Int
    }
    enum Action: Equatable {
        case count
        case fetchCountries(ContextSnapshot)
        case fetchCountryDetails(ContextSnapshot)
        case update(ContextSnapshot)
    }
    var actions = MockActions<Action>(expected: [])
    
    var countResult: Int = 0
    
    deinit {
        destroyDatabase()
    }
    
    // MARK: - count
    
    func count<T>(_ fetchRequest: NSFetchRequest<T>) -> Int {
        register(.count)
        return countResult
    }
    
    // MARK: - fetch
    
    func fetch<T, V>(_ fetchRequest: NSFetchRequest<T>,
                     map: @escaping (T) throws -> V?) -> AnyPublisher<LazyList<V>, Error> {
        do {
            let context = container.viewContext
            context.reset()
            let result = try context.fetch(fetchRequest)
            if T.self is CountryMO.Type {
                register(.fetchCountries(context.snapshot))
            } else if T.self is CountryDetailsMO.Type {
                register(.fetchCountryDetails(context.snapshot))
            } else {
                fatalError("Add a case for \(String(describing: T.self))")
            }
            let list = LazyList<V>(count: result.count, useCache: true, { index in
                try map(result[index])
            })
            return Just<LazyList<V>>.withErrorType(list, Error.self).publish()
        } catch {
            return Fail<LazyList<V>, Error>(error: error).publish()
        }
    }
    
    // MARK: - update
    
    func update<Result>(_ operation: @escaping DBOperation<Result>) -> AnyPublisher<Result, Error> {
        do {
            let context = container.viewContext
            context.reset()
            let result = try operation(context)
            register(.update(context.snapshot))
            return Just(result).setFailureType(to: Error.self).publish()
        } catch {
            return Fail<Result, Error>(error: error).publish()
        }
    }
    
    // MARK: -
    
    func preloadData(_ preload: (NSManagedObjectContext) throws -> Void) throws {
        try preload(container.viewContext)
        if container.viewContext.hasChanges {
            try container.viewContext.save()
        }
        container.viewContext.reset()
    }
    
    // MARK: - Database
    
    private let dbVersion = CoreDataStack.Version(CoreDataStack.Version.actual)
    
    private var dbURL: URL {
        guard let url = dbVersion.dbFileURL(.cachesDirectory, .userDomainMask)
            else { fatalError() }
        return url
    }
    
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: dbVersion.modelName)
        try? FileManager().removeItem(at: dbURL)
        let store = NSPersistentStoreDescription(url: dbURL)
        container.persistentStoreDescriptions = [store]
        let group = DispatchGroup()
        group.enter()
        container.loadPersistentStores { (desc, error) in
            if let error = error {
                fatalError("\(error)")
            }
            group.leave()
        }
        group.wait()
        container.viewContext.mergePolicy = NSOverwriteMergePolicy
        container.viewContext.undoManager = nil
        return container
    }()
    
    private func destroyDatabase() {
        try? container.persistentStoreCoordinator
            .destroyPersistentStore(at: dbURL, ofType: NSSQLiteStoreType, options: nil)
        try? FileManager().removeItem(at: dbURL)
    }
}

extension NSManagedObjectContext {
    var snapshot: MockedPersistentStore.ContextSnapshot {
        .init(inserted: insertedObjects.count,
              updated: updatedObjects.count,
              deleted: deletedObjects.count)
    }
}
