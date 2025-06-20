//
//  DateConversion.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/19/25.
//

import Foundation

func monthAndYearFromDate(_ date: Date) -> Date? {
    let calendar = Calendar.current
    
    let monthAndYearComponent = calendar.dateComponents([.month, .year], from: date)
    
    return calendar.date(from: monthAndYearComponent)
}

func extractTimeFromDate(_ date: Date) -> Date? {
    let calendar = Calendar.current
    
    let hourAndMinuteComponent = calendar.dateComponents([.hour, .minute], from: date)

    return calendar.date(from: hourAndMinuteComponent)
}

func mergeDateAndTime(_ date: Date, _ time: Date) -> Date? {
    let calendar = Calendar.current

    var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
    let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
    
    dateComponents.hour = timeComponents.hour
    dateComponents.minute = timeComponents.minute

    return calendar.date(from: dateComponents)
}

