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
    
    private func expenseExists(id: UUID) -> Bool {
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1 // Only need to check existence

        do {
            let count = try coreDateStackInstance.context.count(for: fetchRequest)
            return count > 0
        } catch let error {
            fatalError("Error fetching existing expense -> \(error.localizedDescription)")
        }
    }
    
    private func deleteAllExpenses() {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Expense.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
            fetchExpenses()
        } catch {
            print("Failed to delete all expenses: \(error.localizedDescription)")
        }
    }

    
    func fetchExpenses() {
        let request = NSFetchRequest<Expense>(entityName: "Expense")
        
        do {
            expenses = try coreDateStackInstance.context.fetch(request)
        } catch let error {
            fatalError("Can't fetch expenses with error -> \(error.localizedDescription)")
        }
    }
    
    func addExpense(_ expense: Expense, _ amount: String, _ category: Category, date: Date, time: Date, _ note: String?) {
        guard let amountValue = Double(amount) else {
            fatalError("Cannot convert amount '\(amount)' to Double.")
        }
        expense.id = UUID()
        expense.amount = amountValue
        expense.category = category
        
        let date = mergeDateAndTime(date, time)
        expense.date = date
        
        if let note = note {
            expense.note = note
        }
        coreDateStackInstance.save()
        fetchExpenses()
    }
    
    func deleteAnExpense(_ expense: Expense) {
        coreDateStackInstance.context.delete(expense)
        coreDateStackInstance.save()
        fetchExpenses()
    }
    
    func updateExpense(_ id: UUID, _ newAmount: String, _ newNote: String?, _ date: Date, _ time: Date, _ category: Category) {
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
                
                let calendar = Calendar.current
                var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
                dateComponents.hour = timeComponents.hour
                dateComponents.minute = timeComponents.minute
                existingExpense.date =  calendar.date(from: dateComponents)
                
                if let note = newNote {
                    existingExpense.note = note
                }
                coreDateStackInstance.save()
                fetchExpenses()
            }
        } catch let error {
            fatalError("Error updating an expense -> \(error.localizedDescription)")
        }
    }
}
