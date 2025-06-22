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
    @State private var startOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var contentWidth: CGFloat = 0
    @State var originalContentWidth: CGFloat = 0
    
    let newContentWidth: CGFloat = 311
    let exposesActionThreshold: CGFloat = 100
    let deleteThreshold: CGFloat = 150
    let endPoint: CGFloat = 50
    
    init(isEditMode: Binding<Bool>, actions: [SwipeAction], @ViewBuilder content: @escaping () -> Content) {
        self._isEditMode = isEditMode
        self.actions = actions
        self.content = content
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if !isDragging {
                    startOffset = offset
                    isDragging = true
                }
                if offset < -endPoint {
                    offset = startOffset + value.translation.width
                }
            }
            .onEnded { value in
                isDragging = false
                withAnimation {
                    if value.translation.width < -exposesActionThreshold {
                        offset = -endPoint
                        contentWidth = newContentWidth
                    } else {
                        offset = 0
                        contentWidth = originalContentWidth
                    }
                }
            }
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                HStack(alignment: .center) {
                    Spacer()
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
                                .frame(width: offset < 0 ? -offset : 0)
                                .clipped()
                        }
                        .tint(.white)
                    }
                }
                content()
                    .frame(width: contentWidth)
                    .onAppear {
                        contentWidth = geometry.size.width
                        originalContentWidth = geometry.size.width
                    }
                    .opacity(isEditMode ? 0.5 : 1)
            }
        }
        .simultaneousGesture(dragGesture, isEnabled: !isEditMode)
        .onChange(of: isEditMode) {newValue in
            withAnimation {
                offset = newValue ? -endPoint : 0
                contentWidth = newValue ? newContentWidth : originalContentWidth
            }
        }
    }
}
