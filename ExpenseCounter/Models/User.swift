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
    static let data = User(name: "Daniel Le", income: 1000, expenses: [
        // March 1, 2025
        Expense(name: "Gym Membership", amount: 30.00, date: "March 01, 2025", category: Category(name: "Health", icon: "heart.fill", color: "#FF69B4")), // pink
        Expense(name: "Protein Powder", amount: 45.00, date: "March 01, 2025", category: Category(name: "Health", icon: "cross.case.fill", color: "#9370DB")), // purple

        // March 9, 2025
        Expense(name: "Books for class", amount: 120.00, date: "March 09, 2025", category: Category(name: "Education", icon: "book.closed", color: "#FFA500")), // orange
        Expense(name: "Online Course", amount: 49.99, date: "March 09, 2025", category: Category(name: "Education", icon: "graduationcap", color: "#008080")), // teal

        // March 10, 2025
        Expense(name: "Electricity Bill", amount: 65.50, date: "March 10, 2025", category: Category(name: "Utilities", icon: "bolt.fill", color: "#FFD700")), // yellow
        Expense(name: "Water Bill", amount: 30.25, date: "March 10, 2025", category: Category(name: "Utilities", icon: "drop.fill", color: "#00FFFF")), // cyan

        // March 12, 2025
        Expense(name: "Grocery shopping", amount: 20.00, date: "March 12, 2025", category: Category(name: "Grocery", icon: "cart", color: "#FF0000")), // red
        Expense(name: "Coffee Beans", amount: 12.99, date: "March 12, 2025", category: Category(name: "Grocery", icon: "cup.and.saucer.fill", color: "#8B4513")), // brown

        // March 13, 2025
        Expense(name: "Gas Refill", amount: 35.25, date: "March 13, 2025", category: Category(name: "Transport", icon: "car.fill", color: "#0000FF")), // blue
        Expense(name: "Bus Pass", amount: 25.00, date: "March 13, 2025", category: Category(name: "Transport", icon: "bus.fill", color: "#4B0082")), // indigo

        // March 15, 2025
        Expense(name: "Netflix Subscription", amount: 15.99, date: "March 15, 2025", category: Category(name: "Entertainment", icon: "film", color: "#800080")), // dark purple
        Expense(name: "Movie Night", amount: 18.00, date: "March 15, 2025", category: Category(name: "Entertainment", icon: "popcorn.fill", color: "#E6E6FA")), // lavender

        // March 18, 2025
        Expense(name: "Dinner at Luigi's", amount: 45.00, date: "March 18, 2025", category: Category(name: "Dining", icon: "fork.knife", color: "#228B22")), // green
        Expense(name: "Dessert at SweetSpot", amount: 14.50, date: "March 18, 2025", category: Category(name: "Dining", icon: "birthday.cake.fill", color: "#98FF98")) // mint green
    ])
}
