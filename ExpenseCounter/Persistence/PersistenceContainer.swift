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
    
    init(inMemory: Bool = false) {
        let container = NSPersistentCloudKitContainer(name: "ExpenseCounter")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            if container.persistentStoreDescriptions.first != nil {
                container.persistentStoreDescriptions.first?.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: cloudKitContainerIdentifier)
            }
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Failed to load stores \(error), \(error.userInfo)")
            }
        }
        self.container = container
        context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
        context.shouldDeleteInaccessibleFaults = true
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
