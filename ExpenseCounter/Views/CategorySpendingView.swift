//
//  CategorySpendingView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/15/25.
//

import SwiftUI

struct CategorySpendingView: View {
    @StateObject private var categoryViewModel = CategoryViewModel()
    @StateObject private var expensesViewModel = ExpenseViewModel()
    let categorySpendingViewModel = CategorySpendingViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(categoryViewModel.categories) { category in
                let sortedExpenses = categorySpendingViewModel.sortExpensesByDateAndCategory(expensesViewModel.expenses, category)
                
                CategoryItemView(category: category, sortedExpenses: sortedExpenses, categorySpendingViewModel: categorySpendingViewModel)
            }
        }
        .padding(.top, 9)
    }
}

struct CategoryItemView: View {
    let category: Category
    let sortedExpenses: [Expense]
    let categorySpendingViewModel: CategorySpendingViewModel
    
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: category.icon ?? ErrorCategory.icon)
                .frame(width: 50, height: 50)
                .foregroundStyle(.white)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: category.colorHex ?? ErrorCategory.colorHex))
                        .shadow(color: Color(hex: category.colorHex ?? ErrorCategory.colorHex).opacity(0.3), radius: 5)
                )
                .font(.system(size: 28))

            VStack(alignment: .leading, spacing: 4) {
                Text(category.name ?? ErrorCategory.name)
                    .foregroundStyle(.black)
                    .font(.title3)
                    .bold()

                if let expense = sortedExpenses.first {
                    HStack(spacing: 8) {
                        Text(expense.date?.formatted(.dateTime.day().month()) ?? "\(Date().formatted(.dateTime.day().month()))")
                        Divider()
                            .frame(minWidth: 2)
                            .frame(maxHeight: 15)
                            .overlay(.black)
                        Text(expense.date?.formatted(.dateTime.hour().minute()) ?? "\(Date().formatted(.dateTime.hour().minute()))")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("CustomDarkGrayColor"))
                } else {
                    Text("No expenses")
                        .font(.subheadline)
                        .foregroundStyle(Color("CustomDarkGrayColor"))
                }
            }

            Spacer()
            
            HStack(spacing: 0) {
                Text("$")
                    .padding(.trailing, 4)
                Text("\(categorySpendingViewModel.calculateTotalExpense(sortedExpenses), specifier: "%.2f")")
            }
            .foregroundStyle(.black)
            .font(.title3)
            .bold()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.white))
                .shadow(color: .black.opacity(0.3), radius: 5)
        )
        .padding(.horizontal)
    }
}

