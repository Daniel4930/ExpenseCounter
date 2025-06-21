//
//  ExpenseFormView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/16/25.
//

import SwiftUI

enum ExpenseFormField: Hashable, CaseIterable {
    case title
    case amount
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
    @State private var keyboardHeight: CGFloat = 0
    @State private var showDatePicker: Bool = false
    @State private var showDate = false
    @FocusState var focusedField: ExpenseFormField?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var expenseViewModel: ExpenseViewModel
    private let coreDataSharedInstance = CoreDataStack.shared
    
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
                CustomSectionView(header: "Title (Optional)") {
                    HStack {
                        TextField(text: $title) {
                            Text("Enter a title")
                                .foregroundStyle(Color("CustomGrayColor"))
                        }
                        Spacer()
                        Image(systemName: "list.bullet.rectangle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    .focused($focusedField, equals: ExpenseFormField.title)
                    .inputFormModifier()
                    .foregroundColor(.black)
                }
                
                CustomSectionView(header: "Amount") {
                    HStack {
                        TextField(text: $amount) {
                            Text("Enter an amount")
                                .foregroundStyle(Color("CustomGrayColor"))
                        }
                        .focused($focusedField, equals: ExpenseFormField.amount)
                        .onChange(of: amount) {newValue in
                            if ExpenseFormView.amountInputValid(newValue) == false {
                                amount = String(newValue.dropLast())
                            }
                            readyToSubmit = ExpenseFormView.validInputsBeforeSubmit(newValue, category, showDate)
                        }
                        Spacer()
                        Text(Locale.current.currencySymbol ?? "$")
                    }
                    .inputFormModifier()
                    .keyboardType(.decimalPad)
                    .foregroundColor( .black)
                }
                
                CustomSectionView(header: "Category") {
                    Button(action: {
                        showCategoryPopUp = true
                    }, label: {
                        HStack {
                            Text(category?.name ?? "Select a category")
                            Spacer()
                            Image(systemName: "list.bullet")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                        }
                    })
                    .inputFormModifier()
                    .popover(isPresented: $showCategoryPopUp) {
                        CategorySelectionGridView(selectedCategory: $category)
                            .presentationDetents([.medium])
                    }
                    .onChange(of: category) { newValue in
                        readyToSubmit = ExpenseFormView.validInputsBeforeSubmit(amount, newValue, showDate)
                    }
                }
                
                CustomSectionView(header: "Date") {
                    Button {
                        showDatePicker = true
                        showDate = true
                    } label: {
                        HStack(spacing: 0) {
                            Text(showDate ? date.formatted(date: .abbreviated, time: .shortened) : "Select a date")
                            Spacer()
                            Image(systemName: "calendar")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                        }
                    }
                    .inputFormModifier()
                    .sheet(isPresented: $showDatePicker) {
                        CustomDatePickerView(date: $date)
                            .presentationDetents([.fraction(0.3)])
                    }
                    .onChange(of: showDate) { newValue in
                        readyToSubmit = ExpenseFormView.validInputsBeforeSubmit(amount, category, newValue)
                    }
                }
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color("CustomGreenColor"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .keyboardHeight($keyboardHeight)
            .padding(.bottom, focusedField == ExpenseFormField.amount ? keyboardHeight : 0)
            .animation(.easeInOut(duration: 0.3), value: focusedField)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                    }
                }
                
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
                
                ToolbarItem(placement: .principal) {
                    Text(navTitle)
                        .foregroundColor(.white)
                        .font(AppFont.customFont(.title2))
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Button {
                        focusedField = ExpenseFormView.switchFocusedState(field: focusedField, direction: 1)
                    } label: {
                        Image(systemName: "chevron.up")
                    }

                    Button {
                        focusedField = ExpenseFormView.switchFocusedState(field: focusedField, direction: -1)
                    } label: {
                        Image(systemName: "chevron.down")
                    }

                    Spacer()

                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .onAppear {
                if isEditMode {
                    guard let id = id, let expense = ExpenseFormView.searchAnExpense(expenseViewModel.expenses, id) else {
                        fatalError("ExpenseFormView: Can't edit a non-existing expense")
                    }
                    amount = String(format: "%.2f", expense.amount)
                    date = expense.date ?? Date()
                    title = expense.title ?? ""
                    category = expense.category
                    showDate = true
                } else {
                    amount = ""
                    date = Date()
                    title = ""
                    category = nil
                }
                readyToSubmit = ExpenseFormView.validInputsBeforeSubmit(amount, category, showDate)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .ignoresSafeArea(.keyboard)
    }
}

private extension ExpenseFormView {
    static func searchAnExpense(_ expenses: [Expense], _ id: UUID) -> Expense? {
        return expenses.first { $0.id == id }
    }
    static func amountInputValid(_ amount: String) -> Bool {
        let amountInputPattern = #"^\d*\.?\d{0,2}$"#
        if (amount.range(of: amountInputPattern, options: .regularExpression) != nil) {
            return true
        }
        return false
    }
    static func validInputsBeforeSubmit(_ amount: String, _ category: Category?, _ showDate: Bool) -> Bool {
        if !amount.isEmpty && category != nil && showDate == true {
            return true
        }
        return false
    }
    static func switchFocusedState(field: ExpenseFormField?, direction: Int) -> ExpenseFormField? {
        guard let field else { return nil }
        let allCases = ExpenseFormField.allCases
        guard var index = allCases.firstIndex(of: field) else { return nil }
        if direction == 1 {
            index -= 1
        } else {
            index += 1
        }
        let size = allCases.count
        if index < 0 {
            index = size - 1
        } else if index >= size {
            index = 0
        }
        return allCases[index]
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
        .padding()
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
