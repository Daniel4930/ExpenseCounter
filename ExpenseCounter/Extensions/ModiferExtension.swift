//
//  ViewExtension.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/15/25.
//

import SwiftUI

extension View {
    func monthOverlay(isSelected: Bool, isDisabled: Bool) -> some View {
        self.modifier(MonthOverlayModifier(isSelected: isSelected, isDisabled: isDisabled))
    }
    
    func inputFormModifier() -> some View {
        self.modifier(InputFormModifier())
    }
    
    //Push the view up when the keyboard appears
    func keyboardHeight(_ state: Binding<CGFloat>) -> some View {
        self.modifier(KeyboardProvider(keyboardHeight: state))
    }
    
    func addExpenseToolbarModifier(_ focusedField: FocusState<AddExpenseFormField?>.Binding, _ readyToSubmit: Binding<Bool>, _ addExpenseViewModel: AddExpenseViewModel) -> some View {
        self.modifier(AddExpenseToolbarModifier(focusedField: focusedField, readyToSubmit: readyToSubmit, addExpenseViewModel: addExpenseViewModel))
    }
}

struct MonthOverlayModifier: ViewModifier {
    let isSelected: Bool
    let isDisabled: Bool

    func body(content: Content) -> some View {
        if isDisabled {
            content
        } else {
            if isSelected {
                content.overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue, lineWidth: 1)
                )
            } else {
                content
            }
        }
    }
}


struct InputFormModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
    }
}

struct KeyboardProvider: ViewModifier {
    var keyboardHeight: Binding<CGFloat>
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification),
                       perform: { notification in
                guard let userInfo = notification.userInfo,
                      let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                                                            
                self.keyboardHeight.wrappedValue = keyboardRect.height
                
            }).onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification),
                         perform: { _ in
                self.keyboardHeight.wrappedValue = 0
            })
    }
}

struct AddExpenseToolbarModifier: ViewModifier {
    @FocusState.Binding var focusedField: AddExpenseFormField?
    @Binding var readyToSubmit: Bool
    @Environment(\.dismiss) private var dismiss
    let addExpenseViewModel: AddExpenseViewModel

    func body(content: Content) -> some View {
        content
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
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Submit")
                            .foregroundColor(readyToSubmit ? .white : Color("CustomGrayColor"))
                    })
                    .disabled(!readyToSubmit)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Add an expense")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Button {
                        focusedField = addExpenseViewModel.switchFocusedState(field: focusedField, direction: 1)
                    } label: {
                        Image(systemName: "chevron.up")
                    }

                    Button {
                        focusedField = addExpenseViewModel.switchFocusedState(field: focusedField, direction: -1)
                    } label: {
                        Image(systemName: "chevron.down")
                    }

                    Spacer()

                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
    }
}
