//
//  CategorizedExpenseListView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/18/25.
//

import SwiftUI

struct CategorizedExpenseListView: View {
    let category: Category
    let date: Date
    
    @State private var editMode = false
    @State private var searchText = ""
    @State private var isAscending = false
    
    @EnvironmentObject var expenseViewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss
    
    var sortedExpenses: [Expense] {
        sortExpensesBeforeDate()
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
                                    .font(AppFont.customFont(font: .bold, .title3))
                            case DateKey.unknown:
                                Text("Unknown")
                                    .font(AppFont.customFont(font: .bold, .title3))
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("CustomGreenColor"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            NavbarTitle(title: date.formatted(.dateTime.month(.wide).year()))
            trailingDeleteButton
        }
    }
}

private extension CategorizedExpenseListView {
    func sortExpensesBeforeDate() -> [Expense] {
        var resultArray: [Expense] = []
        
        for expense in expenseViewModel.expensesOfMonth {
            if expense.category == category {
                resultArray.append(expense)
            }
        }
        return resultArray.sorted { first, second in
            switch (first.date, second.date) {
            case let (date1?, date2?):
                return date1 < date2
            case (nil, _?):
                return false
            case (_?, nil):
                return true
            case (nil, nil):
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
                if let name = category.name, let icon = category.icon, let colorHex = category.colorHex {
                    CategoryIconView(icon: icon, isDefault: category.defaultCategory, hexColor: colorHex)
                    CategoryNameView(name: name, fontColor: .primary)
                }
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
                        .font(AppFont.customFont(.title4))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                HStack {
                    Image(systemName: "clock")
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
            
            AmountTextView(amount: expense.amount, fontSize: .title3, color: .black, font: .bold)
            
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
