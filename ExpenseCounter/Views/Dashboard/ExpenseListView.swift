//
//  ExpenseListView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/18/25.
//

import SwiftUI

struct ExpenseListView: View {
    let category: Category
    let date: Date
    
    @State private var editMode = false
    @State private var searchText = ""
    @State private var isAscending = false

    @EnvironmentObject var expenseViewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss
    
    var sortedExpenses: [Expense] {
        let filtered = sortExpensesByCategoryAndBeforeDate(expenseViewModel.expenses, category, date)
        return isAscending ? filtered.reversed() : filtered
    }
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
    var body: some View {
        VStack(alignment: .center) {
            ExpenseHeader(category: category, totalExpense: {
                calculateTotalExpense(sortedExpenses)
            })
            .padding(.top)
            
            ExpenseSearchAndSortBarView(searchText: $searchText, isAscending: $isAscending)
                .padding(.horizontal)
            
            let filteredExpenses: [Expense] = filterExpense()
            if filteredExpenses.isEmpty {
                NoExpenseFoundView()
                Spacer()
            } else {
                ScrollView {
                    let groupedExpenses = groupExpensesByDay(filteredExpenses).sorted(by: { isAscending ? $0.key < $1.key : $0.key > $1.key })
                    ForEach(groupedExpenses, id: \.key) { (date, expensesForDate) in
                        VStack(alignment: .leading, spacing: 0) {
                            Text(date.formatted(.dateTime.month().day()))
                                .font(AppFont.customFont(font: .bold, .title4))
                            ForEach(expensesForDate) { expense in
                                NavigationLink(
                                    destination: ExpenseFormView(
                                        navTitle: "Edit an expense",
                                        id: expense.id,
                                        isEditMode: true)
                                ) {
                                    CustomSwipeView(
                                        isEditMode: $editMode,
                                        actions: [
                                            SwipeAction(color: .red, systemImage: "trash.fill" ,action: {deleteExpense(expense)})
                                        ],
                                    ) {
                                        ExpenseListItemView(expense: expense)
                                            .disabled(editMode)
                                    }
                                    .padding(.vertical, 10)
                                }
                            }
                        }
                        .padding()
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

private extension ExpenseListView {
    func sortExpensesByCategoryAndBeforeDate(_ expenses: [Expense], _ category: Category, _ date: Date) -> [Expense] {
        var resultArray: [Expense] = []
        let currentDate = monthAndYearFromDate(date)
        for expense in expenses {
            guard let expenseDateRaw = expense.date,
                  let expenseDate = monthAndYearFromDate(expenseDateRaw),
                  let current = currentDate else {
                continue // skip any expense with nil date or formatting error
            }
            if expense.category == category && expenseDate <= current {
                resultArray.append(expense)
            }
        }
        return resultArray.sorted { $0.date! > $1.date! }
    }
    func groupExpensesByDay(_ expenses: [Expense]) -> [Date: [Expense]] {
        Dictionary(grouping: expenses) {
            Calendar.current.startOfDay(for: $0.date ?? Date())
        }
    }
    func calculateTotalExpense(_ expenses: [Expense]) -> Double {
        var total: Double = 0
        for expense in expenses {
            total += expense.amount
        }
        return total
    }
    func filterExpense() -> [Expense] {
        sortedExpenses.filter {
            searchText.isEmpty ||
            $0.title?.localizedCaseInsensitiveContains(searchText) == true
        }
    }
    func deleteExpense(_ expense: Expense) {
        withAnimation {
            expenseViewModel.deleteAnExpense(expense)
        }
    }
}

struct ExpenseHeader: View {
    let category: Category
    let totalExpense: () -> Double
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            VStack {
                CategoryIconView(
                    categoryIcon: category.icon ?? ErrorCategory.icon,
                    isDefault: category.defaultCategory,
                    categoryHexColor: category.colorHex ?? ErrorCategory.colorHex
                )
                CategoryNameView(name: category.name ?? ErrorCategory.name, fontColor: .primary)
            }
            Spacer()
            AmountTextView(amount: totalExpense(), fontSize: .title, color: .primary)
            Spacer()
        }
    }
}

struct ExpenseListItemView: View {
    @ObservedObject var expense: Expense
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                if let title = expense.title {
                    Text(title)
                        .font(AppFont.customFont(font: .bold, .title3))
                }
                HStack {
                    Image(systemName: "clock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                    if let date = expense.date {
                        let hourMinute = date.formatted(.dateTime.hour().minute())
                        Text("\(hourMinute)")
                    } else {
                        Text("Date unavailable")
                    }
                }
            }
            Spacer()
            
            AmountTextView(amount: expense.amount, fontSize: .title3, color: .primary, font: .bold)
            
            Image(systemName: "chevron.right")
        }
        .tint(.black)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.5), radius: 5)
        )
    }
}
