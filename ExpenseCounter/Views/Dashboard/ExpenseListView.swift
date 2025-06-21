//
//  ExpenseListView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/18/25.
//

import SwiftUI

struct ExpenseListView: View {
    @State private var editMode: EditMode = .inactive
    @State private var searchText = ""
    @State private var isAscending = false
    let category: Category
    let date: Date

    @EnvironmentObject var expenseViewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss
    
    var sortedExpenses: [Expense] {
        let filtered = sortExpensesByCategoryAndBeforeDate(expenseViewModel.expenses, category, date)
        return isAscending ? filtered.sorted { $0.date! < $1.date! } : filtered.sorted { $0.date! > $1.date! }
    }

    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                Spacer()
                
                VStack {
                    CategoryIconView(category: category)
                    CategoryNameView(name: category.name ?? "No name", fontColor: .primary)
                }

                Spacer()
                
                AmountTextView(amount: calculateTotalExpense(sortedExpenses), fontSize: .title, color: .primary)
                
                Spacer()
            }
            .padding(.top)
            
            HStack {
                HStack {
                    TextField("Search for a title", text: $searchText)
                    Spacer()
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
                .padding(5)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                )
                Button(action: {
                    hideKeyboard()
                }, label: {
                    Image(systemName: "magnifyingglass")
                })
                
                Spacer()
                
                Button(action: {
                    isAscending.toggle()
                }, label: {
                    Image(systemName: "arrow.up")
                })
            }
            .padding(.horizontal)
            
            let filteredExpenses: [Expense] = filterExpense()
            if filteredExpenses.isEmpty {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("No expenses found...")
                }
                .font(AppFont.customFont(font: .bold, .title2))
                .padding(.top)
                Spacer()
            } else {
                List {
                    let filteredExpenses: [Expense] = filterExpense()
                    let groupedExpenses = groupExpensesByDay(filteredExpenses).sorted(by: { isAscending ? $0.key < $1.key : $0.key > $1.key })
                    ForEach(groupedExpenses, id: \.key) { (date, expensesForDate) in
                        Section {
                            ForEach(expensesForDate) { expense in
                                NavigationLink(destination: ExpenseFormView(navTitle: "Edit an expense", id: expense.id, isEditMode: true)) {
                                    ExpenseListItemView(expense: expense)
                                }
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    let expense = expensesForDate[index]
                                    expenseViewModel.deleteAnExpense(expense)
                                }
                            }
                        } header: {
                            Text(date.formatted(.dateTime.month().day()))
                                .font(AppFont.customFont(font: .bold, .title4))
                        }
                    }
                }
                .listStyle(.grouped)
            }
        }
        .navigationBarBackButtonHidden(true)
        .environment(\.editMode, $editMode)
        .toolbarBackground(Color("CustomGreenColor"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.white)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(date.formatted(.dateTime.month(.wide).year()))
                    .foregroundColor(.white)
                    .font(AppFont.customFont(.title2))
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    editMode = (editMode == .active) ? .inactive : .active
                }) {
                    Text(editMode == .active ? "Done" : "Delete")
                        .foregroundColor(.white)
                }
            }
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
    func deleteExpenses(at offsets: IndexSet) {
        for index in offsets {
            let expense = sortedExpenses[index]
            expenseViewModel.deleteAnExpense(expense)
        }
    }
}

struct ExpenseListItemView: View {
    @ObservedObject var expense: Expense
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title = expense.title {
                Text(title)
                    .font(AppFont.customFont(font: .bold))
                    .padding(.bottom)
            }
            
            HStack {
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
                Spacer()
                AmountTextView(amount: expense.amount, fontSize: .body, color: .primary, font: .regular)
            }
        }
    }
}
