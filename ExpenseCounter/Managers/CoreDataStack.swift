//
//  Persistence.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import CoreData

class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    
    lazy var persistenceContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ExpenseCounter")
        
        container.loadPersistentStores {_, error in
            if let error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        
        return container
    }()
}
