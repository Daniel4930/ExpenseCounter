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
                let sortedExpenses = CategorySpendingView.sortExpensesByCategoryAndBeforeDate(expenseViewModel.expenses, category, date)
                
                if !sortedExpenses.isEmpty {
                    NavigationLink(
                        destination: ExpenseListView (
                            category: category,
                            date: date
                        )
                    ) {
                        CategoryItemView(
                            category: category,
                            firstExpense: sortedExpenses.first,
                            totalSpend: CategorySpendingView.calculateTotalExpense(sortedExpenses),
                        )
                    }
                }
            }
        }
        .padding(.top, 9)
    }
}

private extension CategorySpendingView {
    static func sortExpensesByCategoryAndBeforeDate(_ expenses: [Expense], _ category: Category, _ date: Date) -> [Expense] {
        var resultArray: [Expense] = []
        let currentDate = monthAndYearFromDate(date)
        for expense in expenses {
            guard let expenseDateRaw = expense.date,
                  let expenseDate = monthAndYearFromDate(expenseDateRaw),
                  let current = currentDate else {
                continue
            }
            if expense.category == category && expenseDate <= current {
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
}

struct CategoryItemView: View {
    let category: Category
    let firstExpense: Expense?
    let totalSpend: Double
    
    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .center, spacing: 0) {
                CategoryIconView(category: category)
                    .frame(width: proxy.size.width * 0.15)
                    .padding(.trailing, 5)
                
                VStack(alignment: .leading, spacing: 0) {
                    CategoryNameView(name: category.name ?? "No name")
                    
                    if let expense = firstExpense {
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
                .frame(width: proxy.size.width * 0.35, alignment: .leading)
                
                Spacer()
                
                AmountTextView(amount: totalSpend, fontSize: .title3, color: .black)
            }
            .frame(maxHeight: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.white))
                    .shadow(color: .black.opacity(0.3), radius: 5)
            )
            .padding(.horizontal)
        }
        .frame(height: 80)
    }
}
