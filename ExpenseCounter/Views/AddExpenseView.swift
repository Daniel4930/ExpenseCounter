//
//  AddExpenseView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/16/25.
//

import SwiftUI

struct AddExpenseView: View {
    @State private var amount: String = ""
    @State private var selectedCategory: Category?
    @State private var date: Date = Date()
    @State private var time: Date = Date()
    @State private var showCategoryPopUp = false
    @State private var readyToSubmit = false
    
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
                        .onChange(of: amount) {newValue in
                            if addExpenseViewModel.amountInputValid(newValue) == false {
                                amount = String(newValue.dropLast())
                            }
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
                            Text(selectedCategory?.name ?? "Select a category")
                            
                            Spacer()
                            
                            Image(systemName: "list.bullet")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                        }
                    })
                    .inputFormModifier()
                    .popover(isPresented: $showCategoryPopUp) {
                        CategorySelectionGridView(selectedCategory: $selectedCategory)
                            .presentationDetents([.medium])
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
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Done")
                })
                .disabled(readyToSubmit)
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color("CustomGreenColor"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
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
                    Text("Add an expense")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
        }
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

#Preview {
    AddExpenseView()
}
