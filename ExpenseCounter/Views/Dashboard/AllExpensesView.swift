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
        sortExpensesByDate(expenseViewModel.expenses)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AllExpensesViewTitle()
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
                ScrollView {
                    let sortedGroupExpenses = sortGroupExpenses(groupExpenses)
                    ForEach(sortedGroupExpenses, id: \.key) {date, expenses in
                        
                        VStack(alignment: .leading, spacing: 5) {
                            switch date {
                            case DateKey.known(let actualDate):
                                Text("\(actualDate.formatted(.dateTime.month().day()))")
                                    .font(AppFont.customFont(font: .bold, .title3))
                            case DateKey.unknown:
                                Text("Unknown")
                                    .font(AppFont.customFont(font: .bold, .title3))
                            }
                            
                            ForEach(expenses) { expense in
                                let category = expense.category ?? nil
                                let actions = [
                                    SwipeAction(color: .red, systemImage: "trash.fill") {
                                        deleteAnExpense(expense)
                                    }
                                ]
                                
                                NavigationLink(
                                    destination:
                                        ExpenseFormView(
                                            navTitle: "Edit an expense",
                                            id: expense.id,
                                            isEditMode: true
                                        )
                                ) {
                                    CustomSwipeView(
                                        isEditMode: $editMode,
                                        actions: actions
                                    ) {
                                        HStack(alignment: .center, spacing: 0) {
                                            CategoryIconView(
                                                categoryIcon: category?.icon ?? ErrorCategory.icon,
                                                isDefault: category?.defaultCategory ?? true,
                                                categoryHexColor: category?.colorHex ?? ErrorCategory.colorHex
                                            )
                                            .padding(.trailing, 10)
                                            
                                            ExpenseInfo(
                                                expenseTitle: expense.title ?? nil,
                                                expenseDate: expense.date ?? nil,
                                                categoryName: category?.name ?? ErrorCategory.name,
                                                categoryColorHex: category?.colorHex ?? ErrorCategory.colorHex
                                            )
                                            
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
    func filterExpense() -> [Expense] {
        sortedExpenses.filter {
            searchText.isEmpty ||
            $0.title?.localizedCaseInsensitiveContains(searchText) == true
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

struct AllExpensesViewTitle: View {
    var body: some View {
        Text("Expenses")
            .font(AppFont.customFont(font: .bold, .title))
    }
}
