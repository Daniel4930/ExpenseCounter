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
    
    func fetchCategories() {
        let request = NSFetchRequest<Category>(entityName: "Category")
        
        do {
            categories = try coreDataSharedInstance.context.fetch(request)
        } catch let error {
            fatalError("Can't fetch categories with error -> \(error.localizedDescription)")
        }
    }
    
    func addCategory(_ name: String, _ colorHex: String, _ icon: String) {
        let category = Category(context: coreDataSharedInstance.context)
        category.id = UUID()
        category.name = name
        category.colorHex = colorHex
        category.icon = icon
        category.defaultCategory = false
        
        coreDataSharedInstance.save()
        fetchCategories()
    }
    
    func updateCategory(_ id: UUID, _ name: String, _ colorHex: String, _ icon: String) {
        let fetchRequest: NSFetchRequest = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            if let existingCategory = try coreDataSharedInstance.context.fetch(fetchRequest).first {
                existingCategory.name = name
                existingCategory.colorHex = colorHex
                existingCategory.icon = icon
                
                coreDataSharedInstance.save()
                fetchCategories()
            }
        } catch let error {
            fatalError("Error updating a category -> \(error.localizedDescription)")
        }
    }
    
    func deleteCategory(_ category: Category) {
        coreDataSharedInstance.context.delete(category)
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
}
