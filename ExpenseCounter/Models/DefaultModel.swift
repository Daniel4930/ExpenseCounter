//
//  DefaultModel.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/17/25.
//

struct ErrorCategory {
    static let name = "Uncategorized"
    static let icon = "questionmark"
    static let colorHex = "#FF0000"
}

struct DefaultCategory {
    static let categories: [(id: String, name: String, icon: String, colorHex: String)] = [
        ("food-category-id", "Food", "fork.knife", "#FF9F1C"),
        ("transport-category-id", "Transport", "car.fill", "#2EC4B6"),
        ("shopping-category-id", "Shopping", "bag.fill", "#011627"),
        ("bills-category-id", "Bills", "bolt.fill", "#FFBF69"),
        ("health-category-id", "Health", "heart.fill", "#FF6B6B"),
        ("travel-category-id", "Travel", "airplane", "#6A0572"),
        ("education-category-id", "Education", "book.fill", "#4ECDC4"),
        ("entertainment-category-id", "Entertainment", "gamecontroller.fill", "#E71D36"),
        ("unknown-category-id", "Unknown", "questionmark", "#FF0000")
    ]
}
