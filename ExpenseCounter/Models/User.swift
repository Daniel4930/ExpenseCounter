//
//  User.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import Foundation

struct User: Hashable, Identifiable {
    let id = UUID()
    var firstName: String
    var lastName: String
    var income: Double
    var profileIcon: String
    var categories: [Category]
    var expenses: [Expense]
}


struct MockData {
    static let mockCategories: [Category] = [
        Category(name: "Groceries", icon: "cart.fill", colorHex: "#34C759"),
        Category(name: "Transport", icon: "car.fill", colorHex: "#FF9500"),
        Category(name: "Entertainment", icon: "gamecontroller.fill", colorHex: "#AF52DE"),
        Category(name: "Bills", icon: "bolt.fill", colorHex: "#FF3B30"),
        Category(name: "Dining Out", icon: "fork.knife", colorHex: "#FFD60A")
    ]

    static let mockExpenses: [Expense] = [
        Expense(amount: 82.30, date: .now.addingTimeInterval(-86400 * 5), category: mockCategories[0], note: "Whole Foods"),
        Expense(amount: 15.00, date: .now.addingTimeInterval(-86400 * 4), category: mockCategories[1], note: "Gas refill"),
        Expense(amount: 12.99, date: .now.addingTimeInterval(-86400 * 3), category: mockCategories[2], note: "Spotify"),
        Expense(amount: 120.50, date: .now.addingTimeInterval(-86400 * 2), category: mockCategories[3], note: "Internet bill"),
        Expense(amount: 33.20, date: .now.addingTimeInterval(-86400), category: mockCategories[4], note: "Sushi dinner")
    ]

    static let mockUser = User(
        firstName: "Daniel",
        lastName: "Le",
        income: 4000.00,
        profileIcon: "UserIcon",
        categories: mockCategories,
        expenses: mockExpenses
    )
}
