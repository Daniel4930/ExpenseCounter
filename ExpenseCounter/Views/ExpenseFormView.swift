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
    @State var amount: String
    @State var category: Category?
    @State var date: Date
    @State var time: Date
    @State var note: String
    let navTitle: String
    let id: UUID?
    
    @State var readyToSubmit: Bool = false
    @State private var showCategoryPopUp = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState var focusedField: ExpenseFormField?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack {
                CustomSectionView(header: "Amount") {
                    HStack {
                        Text("$")
                        TextField(text: $amount) {
                            Text("Enter an amount")
                                .foregroundStyle(Color("CustomGrayColor"))
                        }
                        .focused($focusedField, equals: ExpenseFormField.amount)
                        .onChange(of: amount) {newValue in
                            if ExpenseFormView.amountInputValid(newValue) == false {
                                amount = String(newValue.dropLast())
                            }
                            readyToSubmit = ExpenseFormView.validInputsBeforeSubmit(newValue, category)
                        }
                    }
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
                                .foregroundStyle(Color("CustomGrayColor"))
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
                                .foregroundStyle(Color("CustomGrayColor"))
                        }
                    )
                    .inputFormModifier()
                }
                
                CustomSectionView(header: "Note") {
                    TextEditor(text: $note)
                        .focused($focusedField, equals: ExpenseFormField.note)
                        .frame(height: 150)
                        .font(.body)
                        .foregroundColor(.primary)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1)
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
                id,
                ExpenseFormBindings(
                    focusedField: $focusedField,
                    readyToSubmit: $readyToSubmit,
                    amount: $amount,
                    category: $category,
                    date: $date,
                    time: $time,
                    note: $note,
                )
            )
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
