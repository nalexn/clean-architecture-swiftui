//
//  CoreDataStack.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 12.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import CoreData
import Combine

protocol PersistentStore {
    typealias DBOperation<Result> = (NSManagedObjectContext) throws -> Result
    
    func count<T>(_ fetchRequest: NSFetchRequest<T>) -> Int
    func fetch<T, V>(_ fetchRequest: NSFetchRequest<T>,
                     map: @escaping (T) -> V?) -> AnyPublisher<LazyList<V>, Error>
    func update<Result>(_ operation: @escaping DBOperation<Result>) -> AnyPublisher<Result, Error>
}

class CoreDataStack: PersistentStore {
    
    let container: NSPersistentContainer
    private let bgUpdateQueue = DispatchQueue(label: "coredata_update")
    
    init(directory: FileManager.SearchPathDirectory = .documentDirectory, version vNumber: UInt) {
        let version = Version(vNumber)
        container = NSPersistentContainer(name: version.modelName)
        if let url = version.dbFileURL(directory) {
            let store = NSPersistentStoreDescription(url: url)
            container.persistentStoreDescriptions = [store]
        }
        container.viewContext.configureAsReadOnlyContext()
        bgUpdateQueue.suspend()
        container.loadPersistentStores { [weak bgUpdateQueue] (storeDescription, error) in
            if let error = error {
                print("CoreDataStack initialization error: \(error)")
            } else {
                bgUpdateQueue?.resume()
            }
        }
    }
    
    func count<T>(_ fetchRequest: NSFetchRequest<T>) -> Int {
        return (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
    
    func fetch<T, V>(_ fetchRequest: NSFetchRequest<T>,
                     map: @escaping (T) -> V?) -> AnyPublisher<LazyList<V>, Error> {
        assert(Thread.isMainThread)
        return Future<LazyList<V>, Error> { [weak self] promise in
            guard let context = self?.container.viewContext else { return }
            context.performAndWait {
                do {
                    let managedObjects = try context.fetch(fetchRequest)
                    let results = LazyList<V>(count: managedObjects.count, useCache: true) {
                        map(managedObjects[$0])
                    }
                    promise(.success(results))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func update<Result>(_ operation: @escaping DBOperation<Result>) -> AnyPublisher<Result, Error> {
        return Future<Result, Error> { [weak bgUpdateQueue, weak container] promise in
            bgUpdateQueue?.async { [weak container] in
                guard let container = container else { return }
                let context = container.newBackgroundContext()
                context.configureAsUpdateContext()
                context.performAndWait {
                    do {
                        let result = try operation(context)
                        if context.hasChanges {
                            try context.save()
                        }
                        context.reset()
                        promise(.success(result))
                    } catch {
                        context.reset()
                        promise(.failure(error))
                    }
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

// MARK: - Versioning

extension CoreDataStack {
    struct Version {
        private let number: UInt
        
        init(_ number: UInt) {
            self.number = number
        }
        
        var modelName: String {
            return "db_model_v1"
        }
        
        func dbFileURL(_ directory: FileManager.SearchPathDirectory) -> URL? {
            return FileManager.default
                .urls(for: directory, in: .userDomainMask).first?
                .appendingPathComponent(subpathToDB)
        }
        
        private var subpathToDB: String {
            return "db.sql"
        }
    }
}
