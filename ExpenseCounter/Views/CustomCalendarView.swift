//
//  CustomCalendarView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import SwiftUI

struct CustomCalendarView: View {
    @Binding var showCalendar: Bool
    @Binding var date: Date
    @State var currentDate: Date
    @State var selectedDate: Date
    
    var body: some View {
        VStack {
            HStack {
                Text("\(currentDate.formatted(.dateTime.year()))")
                Spacer()
                CurrentDateView(currentDate: $currentDate)
            }
            .padding([.leading, .trailing, .bottom])

            
            MonthGridView(currentDate: $currentDate, selectedDate: $selectedDate, date: $date)

            Button("Done") {
                showCalendar = false
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}

struct CurrentDateView: View {
    @Binding var currentDate: Date
    
    var body: some View {
        HStack(spacing: 30) {
            Button(action: {
                if let newDate = CurrentDateView.decrementYear(date: currentDate) {
                    currentDate = newDate
                }
            }, label: {
                Image(systemName: "chevron.left")
            })
            
            Button(action: {
                if let newDate = CurrentDateView.incrementYear(date: currentDate) {
                    currentDate = newDate
                }
            }, label: {
                Image(systemName: "chevron.right")
            })
        }
        .font(.title2)
    }
}
private extension CurrentDateView {
    static func incrementYear(date: Date, by value: Int = 1) -> Date? {
        Calendar.current.date(byAdding: .year, value: value, to: date)
    }
    static func decrementYear(date: Date, by value: Int = 1) -> Date? {
        Calendar.current.date(byAdding: .year, value: -value, to: date)
    }
}

struct MonthGridView: View {
    let columns = [
        GridItem(.flexible()), GridItem(.flexible()),
        GridItem(.flexible()), GridItem(.flexible())
    ]
    @Binding var currentDate: Date
    @Binding var selectedDate: Date
    @Binding var date: Date
    let calendar = Calendar.current
    let months = Calendar.current.monthSymbols
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(0..<12, id: \.self) { index in
                let monthDate = MonthGridView.dateFrom(year: calendar.component(.year, from: currentDate), month: index + 1)
                let isDisabled = MonthGridView.isMonthOutOfBounds(from: monthDate)
                
                let isSelected = MonthGridView.sameMonthAndYear(selectedDate, monthDate)
                
                Text(months[index])
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .foregroundStyle(isDisabled ? Color.gray : Color.primary)
                    .monthOverlay(isSelected: isSelected, isDisabled: isDisabled)
                    .onTapGesture {
                        if !isDisabled,
                           let newDate = MonthGridView.updateMonth(
                               date: selectedDate,
                               newMonth: index + 1,
                               newYear: calendar.component(.year, from: currentDate)
                           ) {
                            selectedDate = newDate
                            date = newDate
                        }
                    }
                    .disabled(isDisabled)
            }
            .padding(.vertical)
        }
        .padding(.horizontal)
    }
}
private extension MonthGridView {
    static func dateFrom(year: Int, month: Int) -> Date {
        let components = DateComponents(year: year, month: month)
        return Calendar.current.date(from: components) ?? Date()
    }
    static func isMonthOutOfBounds(from date: Date) -> Bool {
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
    static func sameMonthAndYear(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        let comp1 = calendar.dateComponents([.year, .month], from: date1)
        let comp2 = calendar.dateComponents([.year, .month], from: date2)
        return comp1.year == comp2.year && comp1.month == comp2.month
    }
    static func updateMonth(date: Date, newMonth: Int, newYear: Int) -> Date? {
        var components = DateComponents()
        components.year = newYear
        components.month = newMonth
        components.day = 1 // start of the month
        return Calendar.current.date(from: components)
    }
}
