//
//  ExpensesView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/15/25.
//

import SwiftUI

struct ExpensesView: View {
    @Binding var expenses: [Expense]
    let expensesViewModel = ExpensesViewModel()
    
    var body: some View {
        ForEach(expensesViewModel.sortExpensesByDate(expenses: expenses).sorted(by: {$0.key < $1.key}), id: \.key) { date, expenses in
            LazyVStack(spacing: 0) {
                Text("\(date.formatted(.dateTime.day().month().year()))")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 50)
                    .padding(.leading, 5)
                    .background(Color.gray.opacity(0.4))
                    .fontWeight(.bold)
                ForEach(expenses) { expense in
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
