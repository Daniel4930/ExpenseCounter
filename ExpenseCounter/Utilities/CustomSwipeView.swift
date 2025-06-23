//
//  CustomSwipeView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/21/25.
//

import SwiftUI

struct SwipeAction {
    let color: Color
    let systemImage: String
    let action: () -> Void
}

struct CustomSwipeView<Content: View>: View {
    @Binding var isEditMode: Bool
    let actions: [SwipeAction]
    let content: () -> Content
    
    @State private var offset: CGFloat = 0
    let endPoint: CGFloat = 70
    
    init(isEditMode: Binding<Bool>, actions: [SwipeAction], @ViewBuilder content: @escaping () -> Content) {
        self._isEditMode = isEditMode
        self.actions = actions
        self.content = content
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            content()
                .opacity(isEditMode ? 0.5 : 1)
            HStack(alignment: .center) {
                ForEach(Array(actions.enumerated()), id: \.offset) { pair in
                    let action = pair.element
                    Button {
                        action.action()
                    } label: {
                        action.color
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.leading, 10)
                            .overlay(alignment: .center) {
                                Image(systemName: action.systemImage)
                                    .padding(.leading, 10)
                            }
                    }
                    .tint(.white)
                }
            }
            .opacity(isEditMode ? 1 : 0)
            .frame(width: offset < 0 ? -offset : 0)
            .onChange(of: isEditMode) {newValue in
                withAnimation {
                    offset = newValue ? -endPoint : 0
                }
            }
        }
    }
}
