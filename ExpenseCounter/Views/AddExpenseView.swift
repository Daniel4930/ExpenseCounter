//
//  AddExpenseView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/16/25.
//

import SwiftUI

enum AddExpenseFormField: Hashable, CaseIterable {
    case amount
    case note
}

struct AddExpenseView: View {
    @State private var amount: String = ""
    @State private var category: Category?
    @State private var date: Date = Date()
    @State private var time: Date = Date()
    @State private var note: String = ""
    @State private var showCategoryPopUp = false
    @State private var readyToSubmit = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var focusedField: AddExpenseFormField?
    
    @Environment(\.dismiss) private var dismiss
    
    let addExpenseViewModel = AddExpenseViewModel()
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
                        .focused($focusedField, equals: AddExpenseFormField.amount)
                        .onChange(of: amount) {newValue in
                            if addExpenseViewModel.amountInputValid(newValue) == false {
                                amount = String(newValue.dropLast())
                            }
                            readyToSubmit = addExpenseViewModel.validInputsBeforeSubmit(newValue, category)
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
                        readyToSubmit = addExpenseViewModel.validInputsBeforeSubmit(amount, newValue)
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
                        .focused($focusedField, equals: AddExpenseFormField.note)
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
            .padding(.bottom, focusedField == AddExpenseFormField.amount ? keyboardHeight : 0)
            .animation(.easeInOut(duration: 0.3), value: focusedField)
            .offset(y: focusedField == AddExpenseFormField.note ? -keyboardHeight : 0)
            .addExpenseToolbarModifier($focusedField, $readyToSubmit, addExpenseViewModel)
        }
        .scrollDismissesKeyboard(.interactively)
        .ignoresSafeArea(.keyboard)
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
