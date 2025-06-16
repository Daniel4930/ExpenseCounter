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
    let dashboardViewModel: DashboardViewModel
    
    var body: some View {
        HStack {
            Button(action: {
                if let newDate = dashboardViewModel.decrementMonth(date: date) {
                    date = newDate
                }
            }, label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundStyle(.white)
            })
            
            Button(action: {
                showCalendar.toggle()
            }) {
                Text(date.formatted(.dateTime.month().year()))
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            .sheet(isPresented: $showCalendar) {
                CustomCalendarView(showCalendar: $showCalendar, date: $date, currentDate: date, selectedDate: date)
                    .presentationDetents([.medium])
            }
            
            Button(action: {
                if let newDate = dashboardViewModel.incrementMonth(date: date) {
                    if !dashboardViewModel.isMonthOutOfBounds(from: newDate) {
                        date = newDate
                        monthIncreaseDisabled = false
                    } else {
                        monthIncreaseDisabled = true
                    }
                }
            }, label: {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundStyle(monthIncreaseDisabled ? .gray : .white)
                    .onAppear {
                        if let newDate = dashboardViewModel.incrementMonth(date: date) {
                            monthIncreaseDisabled = dashboardViewModel.isMonthOutOfBounds(from: newDate)
                        }
                    }
                    .onChange(of: date) { _ in
                        if let newDate = dashboardViewModel.incrementMonth(date: date) {
                            monthIncreaseDisabled = dashboardViewModel.isMonthOutOfBounds(from: newDate)
                        }
                    }
            })
            .disabled(monthIncreaseDisabled)
        }
        .padding([.top, .bottom], 10)
    }
}
