//
//  ExpensesViewMode.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/15/25.
//

import Foundation

class ExpensesViewModel {
    func sortExpensesByDate(expenses: [Expense]) -> [Date:[Expense]] {
        var sortedExpenses: [Date:[Expense]] = [:]
        for expense in expenses {
            let date = expense.date
            
            if sortedExpenses[date] != nil {
                sortedExpenses[date]?.append(expense)
            } else {
                sortedExpenses[date] = [expense]
            }
        }
        return sortedExpenses
    }
}
