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

struct MockData {
    static let foodCategory = Category(name: "Food", icon: "🍔", color: "#FF6B6B")
    static let transportCategory = Category(name: "Transport", icon: "🚗", color: "#4ECDC4")
    static let shoppingCategory = Category(name: "Shopping", icon: "🛍️", color: "#F7B801")
    static let entertainmentCategory = Category(name: "Entertainment", icon: "🎮", color: "#A29BFE")

    static let expenses: [Expense] = [
        Expense(name: "Groceries", amount: 45.99, date: Date(timeIntervalSinceNow: -86400 * 3), category: foodCategory),
        Expense(name: "Uber Ride", amount: 18.50, date: Date(timeIntervalSinceNow: -86400 * 2), category: transportCategory),
        Expense(name: "New Jeans", amount: 60.00, date: Date(timeIntervalSinceNow: -86400 * 1), category: shoppingCategory),
        Expense(name: "Movie Tickets", amount: 22.00, date: Date(), category: entertainmentCategory),
        Expense(name: "Lunch", amount: 12.75, date: Date(), category: foodCategory),
    ]

    static let data = User(name: "Daniel Le", income: 3000.00, expenses: expenses)
}
