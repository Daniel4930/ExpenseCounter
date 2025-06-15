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
            
            AddAnExpenseButtonView()
            
            ScrollView {
                ForEach(MockData.data.expenses) { expense in
                    LazyVStack(spacing: 0) {
                        Text(expense.date)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 50)
                            .padding(.leading, 5)
                            .background(Color.gray.opacity(0.4))
                            .fontWeight(.bold)
                        HStack {
                            Color(hex: expense.category.color)
                                .frame(maxWidth: 5)
                            VStack(alignment: .leading, spacing: 0) {
                                Text(expense.name)
                                HStack {
                                    Color(hex: expense.category.color)
                                        .frame(width: 7, height: 7)
                                        .clipShape(Circle())
                                    Text(expense.category.name)
                                        .font(.footnote)
                                }
                            }
                            Spacer()
                            Text("$\(expense.amount.formatted(.number.precision(.fractionLength(0...2))))")
                                .padding(.trailing)
                        }
                    }
                }
            }
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
            .foregroundStyle(.primary)

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
        .foregroundStyle(.black)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black, lineWidth: 1)
        )
        .padding([.leading, .trailing, .bottom])
    }
}

struct AddAnExpenseButtonView: View {
    var body: some View {
        Button(action: {
            //TODO: Add a spend
        }, label: {
            Image(systemName: "plus")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 30, maxHeight: 30)
        })
        Text("Add an expense")
            .font(.subheadline)
    }
}
