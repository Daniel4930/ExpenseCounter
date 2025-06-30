//
//  CategorySpendingView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/15/25.
//

import SwiftUI

struct CategorySpendingView: View {
   let date: Date
    
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @EnvironmentObject var expenseViewModel: ExpenseViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(categoryViewModel.categories, id: \.id) { category in
                if !expenseViewModel.getExpensesInCategoryInDate(category, date).isEmpty {
                    NavigationLink(destination: CategorizedExpenseListView(category: category, date: date)) {
                        CategoryItemView(category: category, date: date)
                    }
                }
            }
        }
        .padding(.top, 9)
    }
}

struct CategoryItemView: View {
    let category: Category
    let date: Date
    @EnvironmentObject var expenseViewModel: ExpenseViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            CategoryIconView(
                categoryIcon: category.icon ?? ErrorCategory.icon,
                isDefault: category.defaultCategory,
                categoryHexColor: category.colorHex ?? ErrorCategory.colorHex,
                width: 50,
                height: 50
            )
            .padding(.trailing)
            
            VStack(alignment: .leading, spacing: 0) {
                CategoryNameView(name: category.name ?? "No name", font: .bold)
                
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
            
            AmountTextView(amount: calculateTotalExpense(), fontSize: .title3, color: .black, font: .semibold)
        }
        .padding()
        .padding(.vertical, 3)
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
        let expenses = expenseViewModel.getExpensesInCategoryInDate(category, date)
        let dates = expenses.compactMap{ $0.date }
        return expenses.first{ $0.date == dates.max() }
    }
    func calculateTotalExpense() -> Double {
        var total: Double = 0
        for expense in expenseViewModel.getExpensesInCategoryInDate(category, date) {
            total += expense.amount
        }
        return total
    }
}
