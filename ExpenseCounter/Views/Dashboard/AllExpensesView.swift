//
//  AllExpensesView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/21/25.
//

import SwiftUI
import SwipeActions

struct AllExpensesView: View {
    let date: Date
    
    @State private var searchText = ""
    @State private var isAscending = false
    @State private var editMode = false
    @State private var selectedExpense: Expense? = nil
    @EnvironmentObject var expenseViewModel: ExpenseViewModel
    @Environment(\.dismiss) var dismiss
    
    private var leadingBackButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: { dismiss() }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(.white)
            }
        }
    }
    private var centerTitle: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(date.formatted(.dateTime.month(.wide).year()))
                .foregroundColor(.white)
                .font(AppFont.customFont(.title2))
        }
    }
    private var trailingDeleteButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                editMode.toggle()
            }) {
                Text(editMode ? "Done" : "Delete")
                    .foregroundColor(.white)
            }
        }
    }
    
    var sortedExpenses: [Expense] {
        let sorted = sortExpensesByDate(expenseViewModel.expenses)
        return isAscending ? sorted.reversed() : sorted
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AllExpensesViewTitle()
                .padding()

            ExpenseSearchAndSortBarView(searchText: $searchText, isAscending: $isAscending)
                .padding(.horizontal)
            
            let filteredExpenses = filterExpense()
            if filteredExpenses.isEmpty {
                NoExpenseFoundView()
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                ScrollView {
                    ForEach(filteredExpenses) { expense in
                        let category = expense.category ?? nil
                        
                        GeometryReader { proxy in
                            CustomSwipeView(
                                isEditMode: $editMode,
                                actions: [
                                    SwipeAction(color: .red, systemImage: "trash.fill", action: {deleteAnExpense(expense)})
                                ]
                            ) {
                                HStack(alignment: .center, spacing: 0) {
                                    CategoryIconView(
                                        categoryIcon: category?.icon ?? ErrorCategory.icon,
                                        categoryHexColor: category?.colorHex ?? ErrorCategory.colorHex
                                    )
                                    .frame(width: proxy.size.width * 0.15)
                                    .padding(.trailing, 5)
                                    
                                    ExpenseInfo(
                                        editMode: $editMode,
                                        expenseTitle: expense.title ?? nil,
                                        expenseDate: expense.date ?? nil,
                                        categoryName: category?.name ?? ErrorCategory.name,
                                        categoryColorHex: category?.colorHex ?? ErrorCategory.colorHex
                                    )
                                    .frame(width: proxy.size.width * 0.4, alignment: .leading)
                                    
                                    Spacer()
                                    
                                    AmountTextView(amount: expense.amount, fontSize: editMode ? .subheadline : .title3, color: .black)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.horizontal)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(.white))
                                        .shadow(color: .black.opacity(0.5), radius: 5)
                                )
                            }
                        }
                        .frame(height: 90)
                        .padding(.top)
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Color("CustomGreenColor"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            leadingBackButton
            centerTitle
            trailingDeleteButton
        }
    }
}
private extension AllExpensesView {
    func getExpensesFromDate() -> [Expense] {
        var resultExpenses: [Expense] = []
        for expense in self.sortedExpenses {
            if let date = expense.date, date.formatted(.dateTime.month().day()) == self.date.formatted(.dateTime.month().day()) {
                resultExpenses.append(expense)
            }
        }
        return resultExpenses
    }
    func sortExpensesByDate(_ expenses: [Expense]) -> [Expense] {
        expenses.sorted { lhs, rhs in
            switch (lhs.date, rhs.date) {
            case let (l?, r?):
                return l > r
            case (nil, nil):
                return false
            case (nil, _):
                return false
            case (_, nil):
                return true
            }
        }
    }
    func filterExpense() -> [Expense] {
        sortedExpenses.filter {
            searchText.isEmpty ||
            $0.title?.localizedCaseInsensitiveContains(searchText) == true
        }
    }
    func deleteAnExpense(_ expense: Expense) {
        expenseViewModel.deleteAnExpense(expense)
    }
}

struct ExpenseInfo: View {
    @Binding var editMode: Bool
    let expenseTitle: String?
    let expenseDate: Date?
    let categoryName: String
    let categoryColorHex: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title = expenseTitle {
                Text(title)
                    .foregroundStyle(.black)
            }
            HStack(spacing: 8) {
                if let date = expenseDate {
                    Text(date.formatted(.dateTime.month().day()))
                    Divider()
                        .frame(minWidth: 2)
                        .frame(maxHeight: 15)
                        .overlay(.black)
                    Text(date.formatted(.dateTime.hour().minute()))
                } else {
                    Text("No date")
                }
            }
            .foregroundStyle(Color("CustomDarkGrayColor"))
            .font(AppFont.customFont(font: .semibold, editMode ? .subheadline : .body))
            .padding(.bottom, 7)
            
            HStack(spacing: 2) {
                Circle()
                    .foregroundStyle(Color(hex: categoryColorHex))
                    .frame(width: 10, height: 10)
                Text(categoryName)
                    .foregroundStyle(.black)
            }
            .font(AppFont.customFont(.footnote))
        }
    }
}

struct AllExpensesViewTitle: View {
    var body: some View {
        Text("Expenses")
            .font(AppFont.customFont(font: .bold, .title))
    }
}
