//
//  ExpenseFormView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/16/25.
//

import SwiftUI

enum ExpenseFormField: Hashable, CaseIterable {
    case amount
    case note
}

struct ExpenseFormBindings {
    var focusedField: FocusState<ExpenseFormField?>.Binding
    var readyToSubmit: Binding<Bool>
    var amount: Binding<String>
    var category: Binding<Category?>
    var date: Binding<Date>
    var time: Binding<Date>
    var note: Binding<String>
}

struct ExpenseFormView: View {
    @ObservedObject var expense: Expense
    
    @State var amount: String
    @State var category: Category?
    @State var date: Date
    @State var time: Date
    @State var note: String
    let navTitle: String
    
    @State var readyToSubmit: Bool = false
    @State private var showCategoryPopUp = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState var focusedField: ExpenseFormField?
    
    @Environment(\.dismiss) private var dismiss
    private let coreDataSharedInstance = CoreDataStack.shared
    
    init(expense: Expense?, navTitle: String) {
        if let expense = expense {
            self.expense = expense
            self.amount = String(expense.amount)
            self.category = expense.category
            self.date = expense.date ?? Date()
            self.time = extractTimeFromDate(expense.date!) ?? Date()
            self.note = expense.note ?? ""
            self.navTitle = navTitle
            return
        }
        let context = coreDataSharedInstance.context
        let newExpense = Expense(context: context)
        
        self.expense = newExpense
        self.amount = ""
        self.category = nil
        self.date = Date()
        self.time = Date()
        self.note = ""
        self.navTitle = navTitle
    }
    
    var body: some View {
        ScrollView {
            VStack {
                CustomSectionView(header: "Amount") {
                    HStack {
                        Text("$")
                        TextField(text: $amount) {
                            Text("Enter an amount")
                        }
                        .focused($focusedField, equals: ExpenseFormField.amount)
                        .onChange(of: amount) {newValue in
                            if ExpenseFormView.amountInputValid(newValue) == false {
                                amount = String(newValue.dropLast())
                            }
                            readyToSubmit = ExpenseFormView.validInputsBeforeSubmit(newValue, category)
                        }
                    }
                    .foregroundStyle(.black)
                    .inputFormModifier()
                    .keyboardType(.decimalPad)
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
                        readyToSubmit = ExpenseFormView.validInputsBeforeSubmit(amount, newValue)
                    }
                }
                
                CustomSectionView(header: "Date") {
                    DatePicker(
                        selection: $date,
                        displayedComponents: .date,
                        label: {
                            Text("Select a date")
                                .foregroundStyle(.black)
                        }
                    )
                    .inputFormModifier()
                }
                
                CustomSectionView(header: "Time") {
                    DatePicker(
                        selection: $time,
                        displayedComponents: .hourAndMinute,
                        label: {
                            Text("Select a time")
                                .foregroundStyle(.black)
                        }
                    )
                    .inputFormModifier()
                }
                
                CustomSectionView(header: "Note") {
                    TextEditor(text: $note)
                        .focused($focusedField, equals: ExpenseFormField.note)
                        .frame(height: 150)
                        .font(.body)
                        .foregroundColor(.black)
                        .scrollContentBackground(.hidden)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.primary, lineWidth: 1)
                        )
                }
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color("CustomGreenColor"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .keyboardHeight($keyboardHeight)
            .padding(.bottom, focusedField == ExpenseFormField.amount ? keyboardHeight : 0)
            .animation(.easeInOut(duration: 0.3), value: focusedField)
            .offset(y: focusedField == ExpenseFormField.note ? -keyboardHeight : 0)
            .addExpenseToolbarModifier(
                navTitle,
                expense.id,
                ExpenseFormBindings(
                    focusedField: $focusedField,
                    readyToSubmit: $readyToSubmit,
                    amount: $amount,
                    category: $category,
                    date: $date,
                    time: $time,
                    note: $note,
                ),
                expense
            )
            .onAppear {
                amount = String(format: "%.2f", expense.amount)
                date = expense.date ?? Date()
                time = extractTimeFromDate(expense.date ?? Date()) ?? Date()
                note = expense.note ?? ""
                category = expense.category
                readyToSubmit = ExpenseFormView.validInputsBeforeSubmit(amount, category)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .ignoresSafeArea(.keyboard)
    }
}

private extension ExpenseFormView {
    static func amountInputValid(_ amount: String) -> Bool {
        let amountInputPattern = #"^\d*\.?\d{0,2}$"#
        if (amount.range(of: amountInputPattern, options: .regularExpression) != nil) {
            return true
        }
        return false
    }
    static func validInputsBeforeSubmit(_ amount: String, _ category: Category?) -> Bool {
        if !amount.isEmpty && category != nil {
            return true
        }
        return false
    }
}

struct CustomSectionView<Content: View>: View {
    let header: String
    @ViewBuilder let inputView: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(header)
                .fontWeight(.bold)
            inputView()
                .padding(.top, 5)
        }
        .padding()
    }
}
