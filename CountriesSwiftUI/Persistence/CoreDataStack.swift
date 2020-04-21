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
    
    func count<T>(_ fetchRequest: NSFetchRequest<T>) -> AnyPublisher<Int, Error>
    func fetch<T, V>(_ fetchRequest: NSFetchRequest<T>,
                     map: @escaping (T) throws -> V?) -> AnyPublisher<LazyList<V>, Error>
    func update<Result>(_ operation: @escaping DBOperation<Result>) -> AnyPublisher<Result, Error>
}

struct CoreDataStack: PersistentStore {
    
    private let container: NSPersistentContainer
    private let isStoreLoaded = CurrentValueSubject<Bool, Error>(false)
    private let bgQueue = DispatchQueue(label: "coredata")
    
    init(directory: FileManager.SearchPathDirectory = .documentDirectory,
         domainMask: FileManager.SearchPathDomainMask = .userDomainMask,
         version vNumber: UInt) {
        let version = Version(vNumber)
        container = NSPersistentContainer(name: version.modelName)
        if let url = version.dbFileURL(directory, domainMask) {
            let store = NSPersistentStoreDescription(url: url)
            container.persistentStoreDescriptions = [store]
        }
        bgQueue.async { [weak isStoreLoaded, weak container] in
            container?.loadPersistentStores { (storeDescription, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        isStoreLoaded?.send(completion: .failure(error))
                    } else {
                        container?.viewContext.configureAsReadOnlyContext()
                        isStoreLoaded?.value = true
                    }
                }
            }
        }
    }
    
    func count<T>(_ fetchRequest: NSFetchRequest<T>) -> AnyPublisher<Int, Error> {
        return onStoreIsReady
            .flatMap { [weak container] in
                Future<Int, Error> { promise in
                    do {
                        let count = try container?.viewContext.count(for: fetchRequest) ?? 0
                        promise(.success(count))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetch<T, V>(_ fetchRequest: NSFetchRequest<T>,
                     map: @escaping (T) throws -> V?) -> AnyPublisher<LazyList<V>, Error> {
        assert(Thread.isMainThread)
        let fetch = Future<LazyList<V>, Error> { [weak container] promise in
            guard let context = container?.viewContext else { return }
            context.performAndWait {
                do {
                    let managedObjects = try context.fetch(fetchRequest)
                    let results = LazyList<V>(count: managedObjects.count,
                                              useCache: true) { [weak context] in
                        let object = managedObjects[$0]
                        let mapped = try map(object)
                        if let mo = object as? NSManagedObject {
                            // Turning object into a fault
                            context?.refresh(mo, mergeChanges: false)
                        }
                        return mapped
                    }
                    promise(.success(results))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        return onStoreIsReady
            .flatMap { fetch }
            .eraseToAnyPublisher()
    }
    
    func update<Result>(_ operation: @escaping DBOperation<Result>) -> AnyPublisher<Result, Error> {
        let update = Future<Result, Error> { [weak bgQueue, weak container] promise in
            bgQueue?.async {
                guard let context = container?.newBackgroundContext() else { return }
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
        return onStoreIsReady
            .flatMap { update }
//          .subscribe(on: bgQueue) // Does not work as stated in the docs. Using `bgQueue.async`
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private var onStoreIsReady: AnyPublisher<Void, Error> {
        return isStoreLoaded
            .filter { $0 }
            .map { _ in }
            .eraseToAnyPublisher()
    }
}

// MARK: - Versioning

extension CoreDataStack.Version {
    static var actual: UInt { 1 }
}

extension CoreDataStack {
    struct Version {
        private let number: UInt
        
        init(_ number: UInt) {
            self.number = number
        }
        
        var modelName: String {
            return "db_model_v1"
        }
        
        func dbFileURL(_ directory: FileManager.SearchPathDirectory,
                       _ domainMask: FileManager.SearchPathDomainMask) -> URL? {
            return FileManager.default
                .urls(for: directory, in: domainMask).first?
                .appendingPathComponent(subpathToDB)
        }
        
        private var subpathToDB: String {
            return "db.sql"
        }
    }
}
