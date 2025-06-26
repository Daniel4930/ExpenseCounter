//
//  Persistence.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import CoreData

class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    private init() {
        CoreDataStack.whereIsMySQLite()
        container = NSPersistentContainer(name: "ExpenseCounter")
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        context = container.viewContext
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
