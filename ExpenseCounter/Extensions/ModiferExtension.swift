//
//  ViewExtension.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/15/25.
//

import SwiftUI

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

extension View {
    func monthOverlay(isSelected: Bool, isDisabled: Bool) -> some View {
        self.modifier(MonthOverlayModifier(isSelected: isSelected, isDisabled: isDisabled))
    }
    
    func inputFormModifier() -> some View {
        self.modifier(InputFormModifier())
    }
}
