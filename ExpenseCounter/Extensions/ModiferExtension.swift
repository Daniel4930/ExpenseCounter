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

extension View {
    func monthOverlay(isSelected: Bool, isDisabled: Bool) -> some View {
        self.modifier(MonthOverlayModifier(isSelected: isSelected, isDisabled: isDisabled))
    }
}
