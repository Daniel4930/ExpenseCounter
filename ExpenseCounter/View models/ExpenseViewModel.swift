//
//  ExpenseViewModel.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/17/25.
//

import CoreData

class ExpenseViewModel: ObservableObject {
    @Published var expensesOfMonth: [Expense] = []
    @Published var date: Date
    private let coreDateStackInstance = PersistenceContainer.shared
    
    init() {
        date = ExpenseViewModel.generateDate()
    }
    
    private static func generateDate() -> Date {
        let now = Date()
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.year, .month], from: now)
        
        if let beginningOfMonth = calendar.date(from: components) {
            return beginningOfMonth
        }
        fatalError("Can't get date")
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
    
    func fetchExpensesOfMonthYear() {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        var components = DateComponents()
        components.month = 1
        components.second = -1
        let endOfMonth = calendar.date(byAdding: components, to: startOfMonth)!

        let request = NSFetchRequest<Expense>(entityName: "Expense")
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startOfMonth as NSDate, endOfMonth as NSDate)
        
        do {
            expensesOfMonth = try coreDateStackInstance.context.fetch(request)
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
        
        let formattedDate = getDateAndTime(date)
        expense.date = formattedDate
        
        if let currentTitle = title, currentTitle != "" {
            expense.title = currentTitle
        }
        coreDateStackInstance.save()
        if date.formatted(.dateTime.month().year()) == self.date.formatted(.dateTime.month().year()) {
            fetchExpensesOfMonthYear()
        }
    }
    
    func deleteAnExpense(_ expense: Expense) {
        coreDateStackInstance.context.delete(expense)
        coreDateStackInstance.save()
        fetchExpensesOfMonthYear()
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
                if date.formatted(.dateTime.month().year()) == self.date.formatted(.dateTime.month().year()) {
                    fetchExpensesOfMonthYear()
                }
            }
        } catch let error {
            fatalError("Error updating an expense -> \(error.localizedDescription)")
        }
    }
    
    func getExpensesInCategoryInDate(_ category: Category, _ date: Date) -> [Expense] {
        let expenses = expensesOfMonth.filter { $0.category == category }
        
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        var components = DateComponents()
        components.month = 1
        components.second = -1
        let endOfMonth = calendar.date(byAdding: components, to: startOfMonth)!
        
        var result = [Expense]()
        for expense in expenses {
            if let expenseDate = expense.date {
                if startOfMonth <= expenseDate && expenseDate <= endOfMonth {
                    result.append(expense)
                }
            }
        }
        return result
    }
}
