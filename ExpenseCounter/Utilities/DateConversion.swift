//
//  DateConversion.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/19/25.
//

import Foundation

func monthAndYearFromDate(_ date: Date) -> Date? {
    let calendar = Calendar.current
    
    let monthAndYearComponent = calendar.dateComponents([.year, .month], from: date)
    
    return calendar.date(from: monthAndYearComponent)
}

func dayMonthYearFromDate(_ date: Date) -> Date? {
    let calendar = Calendar.current
    
    let monthAndYearComponent = calendar.dateComponents([.year, .month, .day], from: date)
    
    return calendar.date(from: monthAndYearComponent)
}

func extractTimeFromDate(_ date: Date) -> Date? {
    let calendar = Calendar.current
    
    let hourAndMinuteComponent = calendar.dateComponents([.hour, .minute], from: date)

    return calendar.date(from: hourAndMinuteComponent)
}

func getDateAndTime(_ date: Date) -> Date? {
    let calendar = Calendar.current

    let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)

    return calendar.date(from: dateComponents)
}

