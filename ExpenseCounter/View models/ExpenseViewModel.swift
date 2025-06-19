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
    
    func fetchExpenses() {
        let request = NSFetchRequest<Expense>(entityName: "Expense")
        
        do {
            expenses = try coreDateStackInstance.context.fetch(request)
        } catch let error {
            fatalError("Can't fetch expenses with error -> \(error.localizedDescription)")
        }
    }
    
    func addExpense(_ amount: String, _ category: Category, date: Date, time: Date, _ note: String?) {
        guard let amountValue = Double(amount) else {
            fatalError("Cannot convert amount '\(amount)' to Double.")
        }
        
        let context = coreDateStackInstance.context
        let expense = Expense(context: context)
        expense.id = UUID()
        expense.amount = amountValue
        expense.category = category

        // Merge date and time into one Date
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        expense.date = calendar.date(from: dateComponents)

        if let note = note, !note.isEmpty {
            expense.note = note
        }

        coreDateStackInstance.save()
        fetchExpenses()
    }
}
