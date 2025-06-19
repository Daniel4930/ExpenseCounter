//
//  ExpenseListView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/18/25.
//

import SwiftUI

struct ExpenseListView: View {
    @State private var editMode: EditMode = .inactive
    let category: Category
    let date: Date

    @EnvironmentObject var expenseViewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss
    
    var sortedExpenses: [Expense] {
        ExpenseListView.sortExpensesByCategoryAndBeforeDate(expenseViewModel.expenses, category, date)
    }

    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                Spacer()
                
                VStack {
                    CategoryIconView(category: category)
                    CategoryNameView(category: category)
                }

                Spacer()
                
                AmountTextView(amount: ExpenseListView.calculateTotalExpense(sortedExpenses), font: .title, color: .black)
                
                Spacer()
            }
            .padding(.vertical)

            List {
                ForEach(sortedExpenses) { expense in
                    NavigationLink(destination: ExpenseFormView (
                        amount: String(expense.amount),
                        category: expense.category,
                        date: expense.date!,
                        time: expense.date!,
                        note: expense.note ?? "",
                        navTitle: "Edit an expense",
                        id: expense.id
                    )) {
                        ExpenseListItemView(expense: expense)
                    }
                }
                .onDelete(perform: deleteExpenses)
            }
            .listStyle(.plain)
        }
        .navigationBarBackButtonHidden(true)
        .environment(\.editMode, $editMode)
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
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    editMode = (editMode == .active) ? .inactive : .active
                }) {
                    Text(editMode == .active ? "Done" : "Delete")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

private extension ExpenseListView {
    static func sortExpensesByCategoryAndBeforeDate(_ expenses: [Expense], _ category: Category, _ date: Date) -> [Expense] {
        var resultArray: [Expense] = []
        let calendar = Calendar.current
        
        for expense in expenses {
            let monthAndYearDateComponent = calendar.dateComponents([.month, .year], from: date)
            let monthAndYearExpenseDateComponent = calendar.dateComponents([.month, .year], from: expense.date!)
            
            if expense.category == category && calendar.date(from:monthAndYearExpenseDateComponent)! <= calendar.date(from: monthAndYearDateComponent)! {
                resultArray.append(expense)
            }
        }
        
        return resultArray.sorted { $0.date! > $1.date! }
    }
    static func calculateTotalExpense(_ expenses: [Expense]) -> Double {
        var total: Double = 0
        for expense in expenses {
            total += expense.amount
        }
        return total
    }
    func deleteExpenses(at offsets: IndexSet) {
        for index in offsets {
            let expense = sortedExpenses[index]
            expenseViewModel.deleteAnExpense(expense)
        }
    }
}

struct ExpenseListItemView: View {
    @ObservedObject var expense: Expense
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                if let date = expense.date {
                    let dayMonth = date.formatted(.dateTime.day().month())
                    let hourMinute = date.formatted(.dateTime.hour().minute())
                    Text("Date: \(dayMonth) \(hourMinute)")
                } else {
                    Text("Date unavailable")
                }
                Text("Note: \(expense.note ?? "")")
            }
            
            Spacer()
            
            AmountTextView(amount: expense.amount, font: .title3, color: .black)
        }
    }
}
