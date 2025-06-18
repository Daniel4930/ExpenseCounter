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
    
    func switchFocusedState(field: AddExpenseFormField?, direction: Int) -> AddExpenseFormField? {
        guard let field else { return nil }
        
        let allCases = AddExpenseFormField.allCases
        
        guard var index = allCases.firstIndex(of: field) else { return nil }
        
        if direction == 1 {
            index -= 1
        } else {
            index += 1
        }
        
        let size = allCases.count
        if index < 0 {
            index = size - 1
        } else if index >= size {
            index = 0
        }
        
        return allCases[index]
    }
    
    func validInputsBeforeSubmit(_ amount: String, _ category: Category?) -> Bool {
        if !amount.isEmpty && category != nil {
            return true
        }
        return false
    }
}
