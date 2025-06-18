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
        container = NSPersistentContainer(name: "ExpenseCounter")
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        context = container.viewContext
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
