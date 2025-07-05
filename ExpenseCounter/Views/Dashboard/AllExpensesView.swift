//
//  AllExpensesView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/21/25.
//

import SwiftUI

struct AllExpensesView: View {
    let date: Date
    
    @State private var searchText = ""
    @State private var isAscending = false
    @State private var editMode = false
    @EnvironmentObject var expenseViewModel: ExpenseViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            viewTitle()
                .padding()

            ExpenseSearchAndSortBarView(searchText: $searchText, isAscending: $isAscending)
                .padding(.horizontal)
                .padding(.bottom)
            
            let filteredExpenses = filterExpense()
            let groupExpenses = groupExpensesByDate(filteredExpenses)
            if filteredExpenses.isEmpty {
                NoExpenseFoundView()
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                let sortedGroupExpenses = sortGroupExpenses(groupExpenses)
                ScrollView {
                    ForEach(sortedGroupExpenses, id: \.key) {date, expenses in
                        VStack(alignment: .leading, spacing: 5) {
                            expenseDate(date: date)
                            ForEach(expenses) { expense in
                                if let category = expense.category {
                                    let actions = [
                                        SwipeAction(color: .red, systemImage: "trash.fill") {
                                            deleteAnExpense(expense)
                                        }
                                    ]
                                    ExpenseView(editMode: $editMode, expense: expense, category: category, actions: actions)
                                }
                            }
                        }
                        .padding(.top)
                        .padding(.horizontal)
                    }
                }
            }
        }
        .tint(Color("CustomGreenColor"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("CustomGreenColor"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            NavbarTitle(title: date.formatted(.dateTime.month(.wide).year()))
            deleteButton()
        }
    }
}
private extension AllExpensesView {
    func filterExpense() -> [Expense] {
        expenseViewModel.expensesOfMonth.filter {searchText.isEmpty || $0.title?.localizedCaseInsensitiveContains(searchText) == true
        }
    }
    func sortExpensesByDate(_ expenses: [Expense]) -> [Expense] {
        expenses.sorted { lhs, rhs in
            switch (lhs.date, rhs.date) {
            case let (l?, r?):
                return l < r
            case (nil, nil):
                return false
            case (nil, _):
                return true
            case (_, nil):
                return false
            }
        }
    }
    func groupExpensesByDate(_ filteredExpenses: [Expense]) -> [DateKey:[Expense]] {
        Dictionary(grouping: filteredExpenses) {
            if let date = $0.date {
                DateKey.known(Calendar.current.startOfDay(for: date))
            } else {
                DateKey.unknown
            }
        }
    }
    func sortGroupExpenses(_ groupExpenses: [DateKey:[Expense]]) -> [(key: DateKey, value: [Expense])] {
        groupExpenses
            .sorted {
                lhs, rhs in
                switch (lhs.key, rhs.key) {
                case let (.known(d1), .known(d2)):
                    return isAscending ? d1 < d2 : d1 > d2
                case (.unknown, .known): return false
                case (.known, .unknown): return true
                case (.unknown, .unknown): return false
                }
        }
    }
    func deleteAnExpense(_ expense: Expense) {
        withAnimation {
            expenseViewModel.deleteAnExpense(expense)
        }
    }
    func deleteButton() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                editMode.toggle()
            }) {
                Text(editMode ? "Done" : "Delete")
                    .foregroundColor(.white)
            }
        }
    }
    func viewTitle() -> some View {
        Text("Expenses")
            .font(AppFont.customFont(font: .bold, .title))
    }
    
    func expenseDate(date: DateKey) -> some View {
        switch date {
        case DateKey.known(let actualDate):
            Text("\(actualDate.formatted(.dateTime.month().day()))")
                .font(AppFont.customFont(font: .bold, .title3))
        case DateKey.unknown:
            Text("Unknown")
                .font(AppFont.customFont(font: .bold, .title3))
        }
    }
}

struct ExpenseView: View {
    let formTitle = "Edit an expense"
    @Binding var editMode: Bool
    let expense: Expense
    let category: Category
    let actions: [SwipeAction]
    
    var body: some View {
        NavigationLink(destination: ExpenseFormView(navTitle: formTitle, id: expense.id, isEditMode: true)) {
            CustomSwipeView(isEditMode: $editMode, actions: actions) {
                HStack(alignment: .center, spacing: 0) {
                    if let name = category.name, let icon = category.icon, let colorHex = category.colorHex {
                        CategoryIconView(icon: icon, isDefault: category.defaultCategory, hexColor: colorHex)
                        .padding(.trailing, 10)
                        
                        ExpenseInfo(
                            expenseTitle: expense.title ?? nil,
                            expenseDate: expense.date ?? nil,
                            categoryName: name,
                            categoryColorHex: colorHex
                        )
                    }
                    
                    Spacer()
                    
                    AmountTextView(amount: expense.amount, fontSize: .title3, color: .black)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.white))
                        .shadow(color: .black.opacity(0.5), radius: 5)
                )
            }
            .padding(.vertical, 5)
        }
    }
}

struct ExpenseInfo: View {
    let expenseTitle: String?
    let expenseDate: Date?
    let categoryName: String
    let categoryColorHex: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title = expenseTitle {
                Text(title)
                    .font(AppFont.customFont(.title4))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            HStack(spacing: 8) {
                if let date = expenseDate {
                    Text(date.formatted(.dateTime.hour().minute()))
                } else {
                    Text("No date")
                }
            }
            .foregroundStyle(Color("CustomDarkGrayColor"))
            .font(AppFont.customFont(font: .semibold, .body))
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
