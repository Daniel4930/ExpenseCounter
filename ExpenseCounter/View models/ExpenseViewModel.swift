//
//  ExpenseViewModel.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/17/25.
//

import CoreData

class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    private let coreDateStackInstance = CoreDataStack.shared
    
    init() {
        fetchExpenses()
    }
    
    func expenseExists(id: UUID) -> Bool {
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1

        do {
            let count = try coreDateStackInstance.context.count(for: fetchRequest)
            return count > 0
        } catch let error {
            fatalError("Error fetching existing expense -> \(error.localizedDescription)")
        }
    }
    
    func whereIsMySQLite() {
        let path = FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .last?
            .absoluteString
            .replacingOccurrences(of: "file://", with: "")
            .removingPercentEncoding
        
        print(path ?? "Not found")
    }
    
    func fetchExpenses() {
        let request = NSFetchRequest<Expense>(entityName: "Expense")
        
        do {
            expenses = try coreDateStackInstance.context.fetch(request)
        } catch let error {
            fatalError("Can't fetch expenses with error -> \(error.localizedDescription)")
        }
    }
    
    func addExpense( _ title: String?, _ amount: String, _ category: Category, date: Date) {
        guard let amountValue = Double(amount) else {
            fatalError("Cannot convert amount '\(amount)' to Double.")
        }
        let expense = Expense(context: coreDateStackInstance.context)
        expense.id = UUID()
        expense.amount = amountValue
        expense.category = category
        
        let date = getDateAndTime(date)
        expense.date = date
        
        if let currentTitle = title, currentTitle != "" {
            expense.title = currentTitle
        }
        coreDateStackInstance.save()
        fetchExpenses()
    }
    
    func deleteAnExpense(_ expense: Expense) {
        coreDateStackInstance.context.delete(expense)
        coreDateStackInstance.save()
        fetchExpenses()
    }
    
    func updateExpense(_ id: UUID, _ newTitle: String?, _ newAmount: String, _ category: Category, _ date: Date) {
        guard let amountValue = Double(newAmount) else {
            fatalError("Cannot convert amount '\(newAmount)' to Double.")
        }
        
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1

        do {
            if let existingExpense = try coreDateStackInstance.context.fetch(fetchRequest).first {
                existingExpense.amount = amountValue
                existingExpense.category = category
                existingExpense.date =  getDateAndTime(date)
                
                if let title = newTitle, title != "" {
                    existingExpense.title = title
                }
                coreDateStackInstance.save()
                fetchExpenses()
            }
        } catch let error {
            fatalError("Error updating an expense -> \(error.localizedDescription)")
        }
    }
}
