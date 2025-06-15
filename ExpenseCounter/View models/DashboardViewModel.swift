//
//  DashboardViewModel.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import Foundation

class DashboardViewModel {
    let calendar = Calendar.current
    
    func generateDate() -> Date? {
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: now)
        
        if let beginningOfMonth = calendar.date(from: components) {
            return beginningOfMonth
        }
        return nil
    }
    
    func incrementMonth(date: Date) -> Date? {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: date) {
            return newDate
        }
        return nil
    }
    
    func decrementMonth(date: Date) -> Date? {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: date) {
            return newDate
        }
        return nil
    }
    
    func isMonthOutOfBounds(from date: Date) -> Bool {
        let now = Date()

        let currentComponents = calendar.dateComponents([.year, .month], from: now)
        let dateComponents = calendar.dateComponents([.year, .month], from: date)

        guard let currentMonth = calendar.date(from: currentComponents),
              let checkingMonth = calendar.date(from: dateComponents) else {
            return false
        }

        // Out of bounds if checkingMonth is after currentMonth
        return checkingMonth > currentMonth
    }
}
