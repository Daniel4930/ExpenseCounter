//
//  ExpensesViewMode.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/15/25.
//

import Foundation

class CategoryViewModel {
    func sortExpensesByDate(_ expenses: [Expense]) -> [Expense] {
        return expenses.sorted { $0.date > $1.date }
    }
    
    func calculateTotalExpense(_ expenses: [Expense]) -> Double {
        var total: Double = 0
        
        for expense in expenses {
            total += expense.amount
        }
        
        return total
    }
}
