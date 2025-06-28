//
//  Persistence.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import CoreData

class PersistenceContainer {
    static let shared = PersistenceContainer()
    let container: NSPersistentCloudKitContainer
    let context: NSManagedObjectContext
    let cloudKitContainerIdentifier = "iCloud.com.DanielLe.ExpenseCounter"
    
    init() {
        let container = NSPersistentCloudKitContainer(name: "ExpenseCounter")
        guard (container.persistentStoreDescriptions.first?.url?.path) != nil else {
            fatalError("Could not find persistence container")
        }
        
        //Define where the local store file will live
        let localStoreURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("local.sqlite")
        let localStoreDescription = NSPersistentStoreDescription(url: localStoreURL)
        localStoreDescription.configuration = "Local"
        
        let cloudStoreURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("cloud.sqlite")
        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreURL)
        cloudStoreDescription.configuration = "Cloud"
        
        cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: cloudKitContainerIdentifier)
        
        container.persistentStoreDescriptions = [localStoreDescription, cloudStoreDescription]
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Failed to load stores \(error), \(error.userInfo)")
            }
        }
        self.container = container
        self.context = self.container.viewContext
        self.context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.context.automaticallyMergesChangesFromParent = true
        self.context.shouldDeleteInaccessibleFaults = true
    }
    
    private static func whereIsMySQLite() {
        let path = FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .last?
            .absoluteString
            .replacingOccurrences(of: "file://", with: "")
            .removingPercentEncoding
        
        print(path ?? "Not found")
    }
    
    func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Failed to save the context:", error.localizedDescription)
        }
    }
}
