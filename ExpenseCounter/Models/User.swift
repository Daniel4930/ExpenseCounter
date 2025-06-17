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
}


struct MockData {
    static let category: [Category] = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"

        let foodExpenses = [
            Expense(name: "Lunch", amount: 12.5, date: formatter.date(from: "2025/06/01")!),
            Expense(name: "Groceries", amount: 45.0, date: formatter.date(from: "2025/06/03")!)
        ]

        let transportExpenses = [
            Expense(name: "Bus Ticket", amount: 2.75, date: formatter.date(from: "2025/06/02")!),
            Expense(name: "Gas", amount: 30.0, date: formatter.date(from: "2025/06/05")!)
        ]

        let entertainmentExpenses = [
            Expense(name: "Movie", amount: 15.0, date: formatter.date(from: "2025/06/04")!),
            Expense(name: "Concert", amount: 50.0, date: formatter.date(from: "2025/06/06")!)
        ]

        let categories = [
            Category(name: "Food", icon: "fork.knife", color: "#FF5733", expenses: foodExpenses),
            Category(name: "Transport", icon: "car.fill", color: "#3498DB", expenses: transportExpenses),
            Category(name: "Entertainment", icon: "music.note", color: "#9B59B6", expenses: entertainmentExpenses)
        ]
        
        return categories
    }()
    
    static let user: User = {
        return User(name: "Daniel Le", income: 3000)
    }()
}
