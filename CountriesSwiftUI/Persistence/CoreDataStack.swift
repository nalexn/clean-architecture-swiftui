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
    func fetch<T>(_ fetchRequest: NSFetchRequest<T>) -> AnyPublisher<[T], Error>
    func update<Result>(_ operation: @escaping DBOperation<Result>) -> AnyPublisher<Result, Error>
}

struct CoreDataStack: PersistentStore {
    
    let container: NSPersistentContainer
    private let bgQueue = DispatchQueue(label: "coredata_io")
    
    init(directory: FileManager.SearchPathDirectory = .documentDirectory,
         version vNumber: UInt) {
        let version = Version(vNumber)
        container = NSPersistentContainer(name: version.modelName)
        if let url = version.dbFileURL(directory) {
            let store = NSPersistentStoreDescription(url: url)
            container.persistentStoreDescriptions = [store]
        }
        bgQueue.suspend()
        container.loadPersistentStores { [weak bgQueue] (storeDescription, error) in
            if let error = error {
                print("CoreDataStack initialization error: \(error)")
            } else {
                bgQueue?.resume()
            }
        }
        container.viewContext.configureAsMainContext()
    }
    
    func count<T>(_ fetchRequest: NSFetchRequest<T>) -> Int {
        return (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
    
    func fetch<T>(_ fetchRequest: NSFetchRequest<T>) -> AnyPublisher<[T], Error> {
        return container.viewContext
            .loadAsynchronously(fetchRequest)
            .eraseToAnyPublisher()
    }
    
    func update<Result>(_ operation: @escaping DBOperation<Result>) -> AnyPublisher<Result, Error> {
        return Future<Result, Error> { [weak bgQueue, weak container] promise in
            bgQueue?.async { [weak container] in
                guard let container = container else { return }
                let context = container.newBackgroundContext()
                context.configureAsBackgroundUpdateContext()
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
