//
//  CategoryView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/15/25.
//

import SwiftUI

struct CategoryView: View {
    @State var categories: [Category]
    let categoryViewModel = CategoryViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(categories) { category in
                let sortedExpenses = categoryViewModel.sortExpensesByDate(category.expenses)
                let latestExpense = sortedExpenses.first

                HStack(alignment: .center, spacing: 16) {
                    Image(systemName: category.icon)
                        .frame(width: 50, height: 50)
                        .foregroundStyle(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: category.color))
                                .shadow(color: Color(hex: category.color).opacity(0.3), radius: 5)
                        )
                        .font(.system(size: 28))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name)
                            .foregroundStyle(.black)
                            .font(.title3)
                            .bold()

                        if let latestExpense = latestExpense {
                            HStack(spacing: 8) {
                                Text(latestExpense.date.formatted(.dateTime.day().month()))
                                Divider()
                                    .frame(minWidth: 2)
                                    .frame(maxHeight: 15)
                                    .overlay(.black)
                                Text(latestExpense.date.formatted(.dateTime.hour().minute()))
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
                        Text("\(categoryViewModel.calculateTotalExpense(category.expenses), specifier: "%.2f")")
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
        .padding(.top, 9)
    }
}

