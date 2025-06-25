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
    static let categories: [(name: String, icon: String, colorHex: String)] = [
        ("Food", "fork.knife", "#FF9F1C"),
        ("Transport", "car.fill", "#2EC4B6"),
        ("Entertainment", "gamecontroller.fill", "#E71D36"),
        ("Shopping", "bag.fill", "#011627"),
        ("Bills", "bolt.fill", "#FFBF69"),
        ("Health", "heart.fill", "#FF6B6B"),
        ("Travel", "airplane", "#6A0572"),
        ("Education", "book.fill", "#4ECDC4")
    ]
}
