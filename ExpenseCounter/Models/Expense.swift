//
//  Expense.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import Foundation

struct Expense: Identifiable, Hashable {
    let id = UUID()
    let amount: Double
    let date: Date
    let category: Category
    let note: String?
}
