//
//  OtherExtension.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/17/25.
//

import UIKit
import SwiftUI

extension UIApplication {
    // Hide the keyboard when pressed anywhere outside the textField
    func addTapGestureRecognizer() {
        guard
            let windowScene = connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else { return }

        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing(_:)))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false

        // Optional: only add if not already added
        if !(window.gestureRecognizers?.contains(where: { $0 === tapGesture }) ?? false) {
            window.addGestureRecognizer(tapGesture)
        }
    }
}

extension View {
    //Hide keyboard when pressed the done button on the keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
