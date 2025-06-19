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
}

struct CategoryItemView: View {
    let category: Category
    let firstExpense: Expense?
    let totalSpend: Double
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            CategoryIconView(category: category)
            
            VStack(alignment: .leading, spacing: 4) {
                CategoryNameView(category: category)
                
                if let expense = firstExpense {
                    HStack(spacing: 8) {
                        Text(expense.date?.formatted(.dateTime.day().month()) ?? "Error date")
                        Divider()
                            .frame(minWidth: 2)
                            .frame(maxHeight: 15)
                            .overlay(.black)
                        Text(expense.date?.formatted(.dateTime.hour().minute()) ?? "Error time")
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
            .frame(width: 140, alignment: .leading)

            Spacer()
            
            AmountTextView(amount: totalSpend, font: .title3, color: .black)
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

//#Preview {
//    @State var previewDate = Date()
//
//    return CategorySpendingView(date: $previewDate)
//        .environmentObject(UserViewModel())
//        .environmentObject(CategoryViewModel())
//        .environmentObject(ExpenseViewModel())
//        .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
//}
