//
//  ExpenseListView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/18/25.
//

import SwiftUI

struct ExpenseListView: View {
    @State var expenses: [Expense]
    let category: Category

    @EnvironmentObject var expenseViewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                VStack {
                    CategoryIconView(category: category)
                    CategoryNameView(category: category)
                }
                .frame(maxWidth: .infinity)

                Spacer()
                
                AmountTextView(amount: ExpenseListView.calculateTotalExpense(expenses), font: .title, color: .black)
            }
            .padding(.vertical)
            .padding(.horizontal, 60)

            List {
                ForEach($expenses) { expense in
                    NavigationLink(destination: ExpenseFormView (
                        amount: String(expense.amount.wrappedValue),
                        category: expense.category.wrappedValue,
                        date: expense.date.wrappedValue!,
                        time: expense.date.wrappedValue!,
                        note: expense.note.wrappedValue ?? "",
                        navTitle: "Edit an expense"
                    )) {
                        ExpenseListItemView(expense: expense.wrappedValue)
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Color("CustomGreenColor"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.white)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("Expense")
                    .foregroundColor(.white)
                    .font(.title2)
            }
        }
    }
}

private extension ExpenseListView {
    static func calculateTotalExpense(_ expenses: [Expense]) -> Double {
        var total: Double = 0
        for expense in expenses {
            total += expense.amount
        }
        return total
    }
}

struct ExpenseListItemView: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                if let date = expense.date {
                    let dayMonth = date.formatted(.dateTime.day().month())
                    let hourMinute = date.formatted(.dateTime.hour().minute())
                    Text("Date: \(dayMonth) \(hourMinute)")
                } else {
                    Text("Error: Date unavailable")
                }
                Text("Note: \(expense.note ?? "None")")
            }
            
            Spacer()
            
            HStack(spacing: 0) {
                Text("$")
                    .padding(.trailing, 4)
                Text(String(format: "%.2f", expense.amount))
            }
            .foregroundStyle(.black)
            .font(.title3)
            .bold()
        }
    }
}
