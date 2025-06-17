//
//  Category.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import Foundation

struct Category: Identifiable, Hashable {
    var id = UUID()
    let name: String
    let icon: String
    let colorHex: String
}
