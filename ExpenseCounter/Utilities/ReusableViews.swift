//
//  ReusableViews.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/18/25.
//

import Foundation
import SwiftUI

struct CategoryIconView: View {
    let category: Category
    
    var width: CGFloat = 50
    var height: CGFloat = 50
    var cornerRadius: CGFloat = 10
    var shadowOpacity: Double = 0.3
    var shadowRadius: CGFloat = 5
    var iconFontSize: CGFloat = 28
    
    var body: some View {
        Image(systemName: category.icon ?? ErrorCategory.icon)
            .font(.system(size: iconFontSize))
            .foregroundStyle(.white)
            .frame(width: width, height: height)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(hex: category.colorHex ?? ErrorCategory.colorHex))
                    .shadow(
                        color: Color(hex: category.colorHex ?? ErrorCategory.colorHex)
                            .opacity(shadowOpacity),
                        radius: shadowRadius
                    )
            )
    }
}

struct CategoryNameView: View {
    let category: Category
    var fontColor: Color = .black
    var font: Font = .title3
    var fontWeight: Font.Weight = .bold

    var body: some View {
        Text(category.name ?? ErrorCategory.name)
            .foregroundStyle(fontColor)
            .font(font)
            .fontWeight(fontWeight)
    }
}

struct AmountTextView: View {
    let amount: Double
    let font: Font
    let color: Color

    var body: some View {
        HStack(spacing: 0) {
            Text("$")
                .padding(.trailing, 4)
            Text("\(amount, specifier: "%.2f")")
        }
        .foregroundStyle(color)
        .font(font)
        .bold()
    }
}
