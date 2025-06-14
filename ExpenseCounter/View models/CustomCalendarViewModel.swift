//
//  CustomCalendarViewModel.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import Foundation

class CustomCalendarViewModel {
    func incrementYear(date: Date, by value: Int = 1) -> Date? {
        Calendar.current.date(byAdding: .year, value: value, to: date)
    }

    func decrementYear(date: Date, by value: Int = 1) -> Date? {
        Calendar.current.date(byAdding: .year, value: -value, to: date)
    }
    
    func updateMonth(date: Date, newMonth: Int, newYear: Int) -> Date? {
        var components = DateComponents()
        components.year = newYear
        components.month = newMonth
        components.day = 1 // start of the month
        return Calendar.current.date(from: components)
    }
    
    func isNextYearOutOfBounds(from date: Date) -> Bool {
        if let nextYear = Calendar.current.date(byAdding: .year, value: 1, to: date) {
            return nextYear > Date()
        }
        return false
    }
    
    func isMonthOutOfBounds(from date: Date) -> Bool {
        let calendar = Calendar.current
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
    
    func sameMonthAndYear(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        let comp1 = calendar.dateComponents([.year, .month], from: date1)
        let comp2 = calendar.dateComponents([.year, .month], from: date2)
        return comp1.year == comp2.year && comp1.month == comp2.month
    }

    func dateFrom(year: Int, month: Int) -> Date {
        let components = DateComponents(year: year, month: month)
        return Calendar.current.date(from: components) ?? Date()
    }
}
