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
    
    func inputFormModifier(_ fillColor: Color = .white) -> some View {
        self.modifier(InputFormModifier(fillColor: fillColor))
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
    let fillColor: Color
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(fillColor)
            )
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
    }
}

struct AvatarModifier: ViewModifier {
    let width: CGFloat
    let height: CGFloat
    let space: CGFloat
    let gapColor: Color
    let borderColor: Color
    let borderThickness: CGFloat
    
    init(width: CGFloat, height: CGFloat, space: CGFloat = 3, gapColor: Color = .white, borderColor: Color = .white, borderThickness: CGFloat = 2) {
        self.width = width
        self.height = height
        self.space = space
        self.gapColor = gapColor
        self.borderColor = borderColor
        self.borderThickness = borderThickness
    }
    
    func body(content: Content) -> some View {
        content
            .frame(width: width, height: height)
            .clipShape(Circle())
            .padding(space)
            .foregroundStyle(gapColor)
            .overlay {
                Circle()
                    .stroke(borderColor, lineWidth: borderThickness)
            }
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

struct BackButtonToolBarItem: ToolbarContent {
    @Environment(\.dismiss) var dismiss
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundStyle(.white)
            }
        }
    }
}

struct NavbarTitle: ToolbarContent {
    let title: String
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(title)
                .foregroundColor(.white)
                .font(AppFont.customFont(.title2))
        }
    }
}

protocol FocusableField: Hashable, CaseIterable {}
struct KeyboardToolBarGroup<Field: FocusableField>: ToolbarContent {
    var focusedField: FocusState<Field?>.Binding
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Button {
                focusedField.wrappedValue = switchFocusedState(direction: 1)
            } label: {
                Image(systemName: "chevron.up")
            }

            Button {
                focusedField.wrappedValue = switchFocusedState(direction: -1)
            } label: {
                Image(systemName: "chevron.down")
            }

            Spacer()

            Button("Done") {
                focusedField.wrappedValue = nil
            }
        }
    }
}
private extension KeyboardToolBarGroup {
    func switchFocusedState(direction: Int) -> Field? {
        let allCases = Array(Field.allCases)
        guard let current = focusedField.wrappedValue, var index = allCases.firstIndex(of: current) else { return nil }
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
