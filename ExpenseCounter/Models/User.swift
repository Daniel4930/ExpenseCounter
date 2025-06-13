//
//  User.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import Foundation

struct User: Hashable, Identifiable {
    let id = UUID()
    var name: String
    var income: Double
    var expenses: [Expense]
}
