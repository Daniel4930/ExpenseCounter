//
//  MonthNavigatorView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/15/25.
//

import SwiftUI

struct MonthNavigatorView: View {
    @Binding var showCalendar: Bool
    @Binding var date: Date
    @State private var monthIncreaseDisabled: Bool = false
    
    var body: some View {
        HStack {
            Button(action: {
                if let newDate = decrementMonth(date: date) {
                    date = newDate
                }
            }, label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.white)
            })
            
            Button(action: {
                showCalendar.toggle()
            }) {
                Text(date.formatted(.dateTime.month().year()))
                    .foregroundStyle(.white)
            }
            .sheet(isPresented: $showCalendar) {
                CustomCalendarView(showCalendar: $showCalendar, date: $date, currentDate: date, selectedDate: date)
                    .presentationDetents([.medium])
            }
            .padding(.horizontal)
            
            Button(action: {
                if let newDate = incrementMonth(date: date) {
                    if !isMonthOutOfBounds(from: newDate) {
                        date = newDate
                        monthIncreaseDisabled = false
                    } else {
                        monthIncreaseDisabled = true
                    }
                }
            }, label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(monthIncreaseDisabled ? .gray : .white)
                    .onAppear {
                        if let newDate = incrementMonth(date: date) {
                            monthIncreaseDisabled = isMonthOutOfBounds(from: newDate)
                        }
                    }
                    .onChange(of: date) { _ in
                        if let newDate = incrementMonth(date: date) {
                            monthIncreaseDisabled = isMonthOutOfBounds(from: newDate)
                        }
                    }
            })
            .disabled(monthIncreaseDisabled)
        }
        .font(AppFont.customFont(.title2))
        .padding([.top, .bottom], 10)
    }
}

private extension MonthNavigatorView {
    func incrementMonth(date: Date) -> Date? {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: date) {
            return newDate
        }
        return nil
    }
    func decrementMonth(date: Date) -> Date? {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: date) {
            return newDate
        }
        return nil
    }
    func isMonthOutOfBounds(from date: Date) -> Bool {
        let now = Date()
        let calendar = Calendar.current

        let currentComponents = calendar.dateComponents([.year, .month], from: now)
        let dateComponents = calendar.dateComponents([.year, .month], from: date)

        guard let currentMonth = calendar.date(from: currentComponents),
              let checkingMonth = calendar.date(from: dateComponents) else {
            return false
        }
        return checkingMonth > currentMonth
    }
}
