//
//  CategoryViewModel.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/17/25.
//

import CoreData

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    private let coreDataSharedInstance = CoreDataStack.shared
    
    init() {
        fetchCategories()
        if categories.isEmpty {
            addDefaultCategories()
        }
    }
    
    private func addDefaultCategories() {
        for category in DefaultCategory.categories {
            let newCategory = Category(context: coreDataSharedInstance.context)
            newCategory.id = UUID()
            newCategory.name = category.name
            newCategory.icon = category.icon
            newCategory.colorHex = category.colorHex
            newCategory.defaultCategory = true
        }
        coreDataSharedInstance.save()
        fetchCategories()
    }
    
    //Don't call this in production code
//    private func deleteAllCategories() {
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
//        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//
//        do {
//            try coreDataSharedInstance.context.execute(batchDeleteRequest)
//            try coreDataSharedInstance.context.save()
//            fetchCategories() // refresh the local categories array if needed
//        } catch {
//            print("Failed to delete all categories: \(error)")
//        }
//    }
    
    func fetchCategories() {
        let request = NSFetchRequest<Category>(entityName: "Category")
        
        do {
            categories = try coreDataSharedInstance.context.fetch(request)
        } catch let error {
            fatalError("Can't fetch categories with error -> \(error.localizedDescription)")
        }
    }
}
