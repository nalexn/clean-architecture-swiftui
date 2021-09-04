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

final class CoreDataStack: PersistentStore {
    
    private var container: NSPersistentContainer
    private let isStoreLoaded = CurrentValueSubject<Bool, Error>(false)
    private let bgQueue = DispatchQueue(label: "coredata")
    
    init(version vNumber: UInt, directory: DBFileDirectory = .default) {
        let version = Version(vNumber)
        container = NSPersistentContainer(name: version.modelName)
        bootstrap(version: version, directory: directory)
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
    static var actual: UInt { 2 }
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
        
        func dbFileURL(directory: DBFileDirectory) -> URL? {
            return directory.url(version: number)?
                .appendingPathComponent(subpathToDB)
        }
        
        private var subpathToDB: String {
            return "db.sql"
        }
    }
}

extension CoreDataStack {
    enum DBFileDirectory {
        case `default`
        case custom(URL)
        
        func url(version: UInt) -> URL? {
            switch self {
            case .default:
                let fm = FileManager.default
                if version < 2 {
                    return fm.urls(for: .documentDirectory, in: .userDomainMask).first
                }
                // Replace below with appropriate file URL
                // fm.containerURL(forSecurityApplicationGroupIdentifier: "group.com.my.app")
                return fm.urls(for: .cachesDirectory, in: .userDomainMask).first
            case .custom(let url):
                return url.appendingPathComponent("v_\(version)")
            }
        }
    }
}

// MARK: - Bootstrap

private extension CoreDataStack {
    
    func bootstrap(version: Version, directory: DBFileDirectory) {
        let fm = FileManager.default
        let fileURLs = dbFileURLs(version: version, directory: directory)
        fileURLs
            .map { $0.deletingLastPathComponent() }
            .forEach {
                try? fm.createDirectory(at: $0, withIntermediateDirectories: true, attributes: nil)
            }
        container.persistentStoreDescriptions = fileURLs
            .map { NSPersistentStoreDescription(url: $0) }
        bgQueue.async { [weak self] in
            self?.container.loadPersistentStores { (storeDescription, error) in
                self?.migrateDatabase(to: version, directory: directory)
                DispatchQueue.main.async {
                    if let error = error {
                        self?.isStoreLoaded.send(completion: .failure(error))
                    } else {
                        self?.container.viewContext.configureAsReadOnlyContext()
                        self?.isStoreLoaded.value = true
                    }
                }
            }
        }
    }
    
    func dbFileURLs(version: Version, directory: DBFileDirectory) -> [URL] {
        let currentFileURL = version.dbFileURL(directory: directory)
        if let oldFileURL = Version(1).dbFileURL(directory: directory),
           oldFileURL != currentFileURL,
           FileManager.default.fileExists(atPath: oldFileURL.path) {
            return [oldFileURL, currentFileURL].compactMap { $0 }
        }
        return [currentFileURL].compactMap { $0 }
    }
    
    func migrateDatabase(to version: Version, directory: DBFileDirectory) {
        let coordinator = container.persistentStoreCoordinator
        if let oldFileURL = Version(1).dbFileURL(directory: directory),
           let currentFileURL = version.dbFileURL(directory: directory), oldFileURL != currentFileURL,
           let oldStore = coordinator.persistentStore(for: oldFileURL),
           let storeType = container.persistentStoreDescriptions
                .first(where: { $0.url == oldFileURL })?.type {
            do {
                try coordinator.migratePersistentStore(
                    oldStore, to: currentFileURL, options: nil, withType: storeType)
                let fileCoordinator = NSFileCoordinator(filePresenter: nil)
                fileCoordinator.coordinate(writingItemAt: oldFileURL, options: .forDeleting,
                                           error: nil, byAccessor: { url in
                    do {
                        try FileManager.default.removeItem(at: url)
                    } catch {
                        print("Error delieting old DB file: \(error)")
                    }
                })
            } catch {
                print("Error migrating DB to new file location: \(error)")
            }
        }
    }
}
