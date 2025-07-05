//
//  ExpenseFormView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/16/25.
//

import SwiftUI

enum ExpenseFormField: FocusableField {
    case title
    case amount
    case category
    case date
}

struct ExpenseFormView: View {
    let navTitle: String
    let id: UUID?
    var isEditMode: Bool
    
    @State var amount: String
    @State var category: Category?
    @State var date: Date
    @State var title: String
    @State var readyToSubmit: Bool = false
    @State private var showCategoryPopUp = false
    @State private var showDatePicker: Bool = false
    @FocusState var focusedField: ExpenseFormField?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var expenseViewModel: ExpenseViewModel
    
    init(navTitle: String, id: UUID?, isEditMode: Bool) {
        self.navTitle = navTitle
        self.id = id
        self.isEditMode = isEditMode
        
        self.amount = ""
        self.category = nil
        self.date = Date()
        self.title = ""
    }
    
    var body: some View {
        ScrollView {
            VStack {
                CustomSectionView(header: "Title") {
                    titleTextField()
                        .inputFormModifier()
                        .foregroundColor(.black)
                }
                .padding()
                
                CustomSectionView(header: "Amount") {
                    amountTextField()
                        .inputFormModifier()
                        .keyboardType(.decimalPad)
                        .foregroundColor( .black)
                }
                .padding()
                
                CustomSectionView(header: "Category") {
                    categorySelectionView()
                }
                .padding()
                
                CustomSectionView(header: "Date") {
                    dateSelectionView()
                }
                .padding()
                
                Spacer()
            }
            .tint(Color("CustomGreenColor"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("CustomGreenColor"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .animation(.easeInOut(duration: 0.3), value: focusedField)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if isEditMode {
                            expenseViewModel.updateExpense(id!, title, amount, category!, date)
                        } else {
                            expenseViewModel.addExpense(title, amount, category!, date: date)
                        }
                        dismiss()
                    } label: {
                        Text("Submit")
                            .foregroundColor(readyToSubmit ? .white : Color("CustomGrayColor"))
                    }
                    .disabled(!readyToSubmit)
                }
                NavbarTitle(title: navTitle)
                KeyboardToolbarGroup(focusedField: $focusedField)
            }
            .onAppear {
                if isEditMode {
                    guard let id = id, let expense = searchAnExpense(expenseViewModel.expensesOfMonth, id) else {
                        fatalError("ExpenseFormView: Can't edit a non-existing expense")
                    }
                    amount = String(format: "%.2f", expense.amount)
                    date = expense.date ?? Date()
                    title = expense.title ?? ""
                    category = expense.category
                } else {
                    amount = ""
                    date = Date()
                    title = ""
                    category = nil
                }
                readyToSubmit = validInputsBeforeSubmit(amount, category)
            }
        }
    }
}

private extension ExpenseFormView {
    func searchAnExpense(_ expenses: [Expense], _ id: UUID) -> Expense? {
        return expenses.first { $0.id == id }
    }
    func amountInputValid(_ amount: String) -> Bool {
        let amountInputPattern = #"^\d*\.?\d{0,2}$"#
        if (amount.range(of: amountInputPattern, options: .regularExpression) != nil) {
            return true
        }
        return false
    }
    func validInputsBeforeSubmit(_ amount: String, _ category: Category?) -> Bool {
        if !amount.isEmpty && category != nil {
            return true
        }
        return false
    }
    func titleTextField() -> some View {
        HStack {
            CustomTextField(focusedField: $focusedField, text: $title, field: .title) {
                Text("Enter a title")
                    .foregroundStyle(Color("CustomGrayColor"))
            }
            Spacer()
            Image(systemName: "list.bullet.rectangle")
                .foregroundStyle(Color("CustomGreenColor"))
        }
    }
    func amountTextField() -> some View {
        HStack {
            CustomTextField(focusedField: $focusedField, text: $amount, field: .amount) {
                Text("Enter an amount")
                    .foregroundStyle(Color("CustomGrayColor"))
            }
            .onChange(of: amount) {newValue in
                if !amountInputValid(newValue) && !newValue.isEmpty {
                    amount = String(newValue.dropLast())
                }
                readyToSubmit = validInputsBeforeSubmit(amount, category)
            }
            Spacer()
            Text(Locale.current.currencySymbol ?? "$")
                .foregroundStyle(Color("CustomGreenColor"))
        }
    }
    func categorySelectionView() -> some View {
        Button(action: {
            showCategoryPopUp = true
        }, label: {
            HStack {
                Text(category?.name ?? "Select a category")
                Spacer()
                Image(systemName: "list.bullet")
            }
        })
        .inputFormModifier()
        .popover(isPresented: $showCategoryPopUp) {
            CategorySelectionGridView(selectedCategory: $category)
                .presentationDetents([.medium])
        }
        .onChange(of: category) { newValue in
            readyToSubmit = validInputsBeforeSubmit(amount, newValue)
        }
    }
    func dateSelectionView() -> some View {
        Button {
            showDatePicker = true
        } label: {
            HStack(spacing: 0) {
                Text(date.formatted(date: .abbreviated, time: .shortened))
                Spacer()
                Image(systemName: "calendar")
            }
        }
        .inputFormModifier()
        .sheet(isPresented: $showDatePicker) {
            CustomDatePickerView(date: $date)
                .presentationDetents([.medium])
        }
    }
}

struct CustomSectionView<Content: View>: View {
    let header: String?
    @ViewBuilder let inputView: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let header = header {
                Text(header)
                    .font(AppFont.customFont(font: .bold))
            }
            inputView()
                .padding(.top, 5)
        }
    }
}

struct CustomDatePickerView: View {
    @Binding var date: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Select a date")
                .font(AppFont.customFont(.title2))
                .padding(.vertical)
            
            Spacer()
            
            DatePicker("", selection: $date, in: ...Date())
                .labelsHidden()
            
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding(.vertical, 50)
        }
    }
}
