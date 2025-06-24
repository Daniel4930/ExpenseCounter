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
        sortExpensesByCategoryAndBeforeDate()
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
                    let groupedExpenses = groupExpensesByDate(filteredExpenses)
                    let sortedGroupExpenses = sortGroupExpenses(groupedExpenses)
                    ForEach(sortedGroupExpenses, id: \.key) { date, expensesForDate in
                        VStack(alignment: .leading, spacing: 0) {
                            switch date {
                            case DateKey.known(let actualDate):
                                Text("\(actualDate.formatted(.dateTime.month().day()))")
                                    .font(AppFont.customFont(font: .bold, .title4))
                            case DateKey.unknown:
                                Text("Unknown")
                                    .font(AppFont.customFont(font: .bold, .title4))
                            }
                            
                            ForEach(expensesForDate) { expense in
                                let actions = [
                                    SwipeAction(color: .red, systemImage: "trash.fill") {
                                        deleteExpense(expense)
                                    }
                                ]
                                
                                NavigationLink(
                                    destination: ExpenseFormView(
                                        navTitle: "Edit an expense",
                                        id: expense.id,
                                        isEditMode: true)
                                ) {
                                    CustomSwipeView(isEditMode: $editMode, actions: actions) {
                                        ExpenseListItemView(expense: expense)
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
    func sortExpensesByCategoryAndBeforeDate() -> [Expense] {
        var resultArray: [Expense] = []
        let currentDate = date.formatted(.dateTime.month())
        for expense in expenseViewModel.expenses {
            guard let expenseDate = expense.date else { continue }
            let expenseDateFormatted = expenseDate.formatted(.dateTime.month())
            
            //If the expenses are in the same category and in the same month
            if expense.category == category && expenseDateFormatted == currentDate {
                resultArray.append(expense)
            }
        }
        //date is force-wrapped because the guard statement guarantees its safety
        return resultArray.sorted { $0.date! < $1.date! }
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
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
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
