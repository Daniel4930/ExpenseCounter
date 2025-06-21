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
