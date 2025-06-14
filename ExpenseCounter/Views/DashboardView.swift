//
//  DashboardView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import SwiftUI

struct DashboardView: View {
    @State private var date: Date
    @State private var showCalendar = false
    let dashboardViewModel = DashboardViewModel()
    
    init() {
        _date = State(initialValue: dashboardViewModel.generateDate() ?? Date())
    }
    
    var body: some View {
        VStack {
            VStack {
                Header()
                TotalSpendingView(totalSpending: 90.81)
                DateView(showCalendar: $showCalendar, date: $date, dashboardViewModel: dashboardViewModel)
            }
            .background(Color("MainColor"))
            
            Spacer()
        }
    }
}

struct Header: View {
    var body: some View {
        HStack {
            Text("Dashboard")
                .font(.system(size: 25, weight: .bold, design: .default))
            
            Spacer()
            
            Button(action: {
                //TODO: View profile
            }, label: {
                Image(systemName: "face.smiling")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            })
            .foregroundStyle(.white)

        }
        .padding()
    }
}

struct TotalSpendingView: View {
    var totalSpending: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Spends")
                    .font(.system(.title, weight: .bold))
                Text("$\(totalSpending.formatted(.number.precision(.fractionLength(0...2))))")
                    .font(.system(.title2))
            }
            .padding()

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black, lineWidth: 1)
        )
        .padding([.leading, .trailing, .bottom])
    }
}

struct DateView: View {
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
        .padding(.bottom)
    }
}
