//
//  Expense.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import Foundation

struct Expense: Hashable, Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let date: Date
    
    //let note: String?
}
