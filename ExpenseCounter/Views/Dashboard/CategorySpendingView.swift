//
//  CategorySpendingView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/15/25.
//

import SwiftUI

struct CategorySpendingView: View {
    @Binding var date: Date
    
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @EnvironmentObject var expenseViewModel: ExpenseViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(categoryViewModel.categories, id: \.id) { category in
                let expenses = expenseViewModel.fetchExpensesInCategory(category)
                if !expenses.isEmpty {
                    NavigationLink(
                        destination: ExpenseListView (
                            category: category,
                            date: date
                        )
                    ) {
                        CategoryItemView(
                            category: category,
                            expensesInCategory: expenses
                        )
                    }
                }
            }
        }
        .padding(.top, 9)
    }
}

private extension CategorySpendingView {
    func calculateTotalExpense(_ expenses: [Expense]) -> Double {
        var total: Double = 0
        for expense in expenses {
            total += expense.amount
        }
        return total
    }
}

struct CategoryItemView: View {
    let category: Category
    let expensesInCategory: [Expense]
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            CategoryIconView(
                categoryIcon: category.icon ?? ErrorCategory.icon,
                isDefault: category.defaultCategory,
                categoryHexColor: category.colorHex ?? ErrorCategory.colorHex
            )
            .padding(.trailing, 9)
            
            VStack(alignment: .leading, spacing: 0) {
                CategoryNameView(name: category.name ?? "No name")
                
                if let expense = getLastestExpense() {
                    HStack(spacing: 8) {
                        Text(expense.date?.formatted(.dateTime.day().month()) ?? "Error date")
                        Divider()
                            .frame(minWidth: 2)
                            .frame(maxHeight: 15)
                            .overlay(.black)
                        Text(expense.date?.formatted(.dateTime.hour().minute()) ?? "Error time")
                    }
                    .font(AppFont.customFont(font: .semibold ,.subheadline))
                    .foregroundStyle(Color("CustomDarkGrayColor"))
                } else {
                    Text("No date available")
                        .font(AppFont.customFont(.subheadline))
                        .foregroundStyle(Color("CustomDarkGrayColor"))
                }
            }
            
            Spacer()
            
            AmountTextView(amount: calculateTotalExpense(), fontSize: .title3, color: .black)
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

extension CategoryItemView {
    func getLastestExpense() -> Expense? {
        let dates = expensesInCategory.compactMap{ $0.date }
        return expensesInCategory.first{ $0.date == dates.max() }
    }
    func calculateTotalExpense() -> Double {
        var total: Double = 0
        for expense in expensesInCategory {
            total += expense.amount
        }
        return total
    }
}
