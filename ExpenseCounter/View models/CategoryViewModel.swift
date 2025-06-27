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
    
//    init() {
//        fetchCategories()
//
//        if defaultCategories.isEmpty {
//            addDefaultCategories()
//        }
//    }
    
    func addDefaultCategories() {
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
    
    private func searchCategory(_ id: UUID) -> Category? {
        let fetchRequest: NSFetchRequest = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
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
    
    func getCustomCategories() {
        customCategories = categories.filter { $0.defaultCategory == false }
    }
    
    func getDefaultCategories() {
        defaultCategories = categories.filter { $0.defaultCategory == true }
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
        let searchedCategory = searchCategory(id)
        
        if searchedCategory != nil {
            searchedCategory?.name = name
            searchedCategory?.colorHex = colorHex
            searchedCategory?.icon = icon
            
            coreDataSharedInstance.save()
            fetchCategories()
        } else {
            fatalError("Error updating a category")
        }
    }
    
    func deleteCategory(_ id: UUID) {
        let searchedCategory = searchCategory(id)
        
        if let category = searchedCategory {
            coreDataSharedInstance.context.delete(category)
            coreDataSharedInstance.save()
            fetchCategories()
        } else {
            fatalError("Error deleting a category")
        }
    }
}
