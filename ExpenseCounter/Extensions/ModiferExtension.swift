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
    
    func addExpenseToolbarModifier(
        _ navTitle: String,
        _ bindings: ExpenseFormBindings,
    ) -> some View {
        self.modifier(AddExpenseToolbarModifier(
            navTitle: navTitle,
            binding: bindings,
        ))
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
    let navTitle: String
    var binding: ExpenseFormBindings
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var expenseViewModel: ExpenseViewModel

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
                        expenseViewModel.addExpense(
                            binding.amount.wrappedValue,
                            binding.category.wrappedValue!,
                            date: binding.date.wrappedValue,
                            time: binding.time.wrappedValue,
                            binding.note.wrappedValue
                        )
                        dismiss()
                    }, label: {
                        Text("Submit")
                            .foregroundColor(binding.readyToSubmit.wrappedValue ? .white : Color("CustomGrayColor"))
                    })
                    .disabled(!binding.readyToSubmit.wrappedValue)
                }
                
                ToolbarItem(placement: .principal) {
                    Text(navTitle)
                        .foregroundColor(.white)
                        .font(.title2)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Button {
                        binding.focusedField.wrappedValue = AddExpenseToolbarModifier.switchFocusedState(field: binding.focusedField.wrappedValue, direction: 1)
                    } label: {
                        Image(systemName: "chevron.up")
                    }

                    Button {
                        binding.focusedField.wrappedValue = AddExpenseToolbarModifier.switchFocusedState(field: binding.focusedField.wrappedValue, direction: -1)
                    } label: {
                        Image(systemName: "chevron.down")
                    }

                    Spacer()

                    Button("Done") {
                        binding.focusedField.wrappedValue = nil
                    }
                }
            }
    }
}

private extension AddExpenseToolbarModifier {
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
