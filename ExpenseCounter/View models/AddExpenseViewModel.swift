//
//  AddExpenseViewModel.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/17/25.
//

import Foundation

class AddExpenseViewModel {
    let amountInputPattern = #"^\d*\.?\d{0,2}$"#
    
    func amountInputValid(_ amount: String) -> Bool {
        if (amount.range(of: amountInputPattern, options: .regularExpression) != nil) {
            return true
        }
        return false
    }
}
