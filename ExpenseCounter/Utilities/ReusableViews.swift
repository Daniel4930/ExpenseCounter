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
    let width: CGFloat = 50
    let height: CGFloat = 50
    let cornerRadius: CGFloat = 10
    let shadowOpacity: Double = 0.3
    let shadowRadius: CGFloat = 5
    let iconFontSize: CGFloat = 28
    let color: Color = .white
    
    var body: some View {
        Image(systemName: category.icon ?? ErrorCategory.icon)
            .font(.system(size: iconFontSize))
            .foregroundStyle(color)
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
