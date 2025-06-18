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
    }
    
    func fetchCategories() {
        let request = NSFetchRequest<Category>(entityName: "Category")
        
        do {
            categories = try coreDataSharedInstance.context.fetch(request)
        } catch let error {
            fatalError("Can't fetch categories with error -> \(error.localizedDescription)")
        }
    }
}
