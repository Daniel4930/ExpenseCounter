//
//  CategoryViewModel.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/17/25.
//

import CoreData

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var customCategories: [Category] = []
    @Published var defaultCategories: [Category] = []
    private let coreDataSharedInstance = PersistenceContainer.shared
    
    init() {
        fetchCategories()
        if defaultCategories.isEmpty {
            addDefaultCategories()
        }
    }
    
    private func addDefaultCategories() {
        for defaultCategory in DefaultCategory.categories {
            let category = Category(context: coreDataSharedInstance.context)
            category.id = defaultCategory.id
            category.name = defaultCategory.name
            category.colorHex = defaultCategory.colorHex
            category.defaultCategory = true
            category.icon = defaultCategory.icon
            coreDataSharedInstance.save()
        }
        fetchCategories()
    }

    func searchCategory(_ id: String) -> Category? {
        let fetchRequest: NSFetchRequest = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.fetchLimit = 1
        
        do {
            if let category = try coreDataSharedInstance.context.fetch(fetchRequest).first {
                return category
            }
        } catch let error {
            fatalError("Can't search for a category -> \(error.localizedDescription)")
        }
        return nil
    }
    
    func fetchCategories() {
        let request = NSFetchRequest<Category>(entityName: "Category")
        
        do {
            categories = try coreDataSharedInstance.context.fetch(request)
            customCategories = categories.filter { $0.defaultCategory == false }
            defaultCategories = categories.filter { $0.defaultCategory == true }
            
        } catch let error {
            fatalError("Can't fetch categories with error -> \(error.localizedDescription)")
        }
    }
    
    func addCategory(_ name: String, _ colorHex: String, _ icon: String) {
        let category = Category(context: coreDataSharedInstance.context)
        category.id = UUID().uuidString
        category.name = name
        category.colorHex = colorHex
        category.icon = icon
        category.defaultCategory = false
        
        coreDataSharedInstance.save()
        fetchCategories()
    }
    
    func updateCategory(_ id: String, _ name: String, _ colorHex: String, _ icon: String) {
        if let searchedCategory = searchCategory(id) {
            searchedCategory.name = name
            searchedCategory.colorHex = colorHex
            searchedCategory.icon = icon
            
            coreDataSharedInstance.save()
            fetchCategories()
        } else {
            fatalError("Error updating a category")
        }
    }
    
    func deleteCategory(_ id: String) {
        let searchedCategory = searchCategory(id)
        let unknownCategory = searchCategory("unknown-category-id")
        
        if let category = searchedCategory, let expenses = category.expenses {
            for expense in expenses.allObjects as! [Expense] {
                expense.category = unknownCategory
            }
            coreDataSharedInstance.context.delete(category)
            coreDataSharedInstance.save()
            fetchCategories()
        } else {
            fatalError("Error deleting a category")
        }
    }
}
