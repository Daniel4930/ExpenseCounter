//
//  ReusableViews.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/18/25.
//

import Foundation
import SwiftUI

enum DateKey: Hashable {
    case known(Date)
    case unknown
}

enum FontSize: CGFloat {
    case largeTitle = 34
    case title = 28
    case title2 = 22
    case title3 = 20
    case title4 = 19
    case body = 17
    case callout = 16
    case subheadline = 15
    case footnote = 13
    case caption = 12
    case caption2 = 11
}

enum CustomFont: String {
    case regular = "OpenSans-Regular"
    case bold = "OpenSans-Bold"
    case semibold = "OpenSans-Semibold"
}

struct AppFont {
    static let font: CustomFont = .regular
    
    static func customFont(font: CustomFont = .regular, _ size: FontSize = .body) -> Font {
        .custom(font.rawValue, size: size.rawValue)
    }
}

struct CategoryIconView: View {
    let categoryIcon: String
    let isDefault: Bool
    let categoryHexColor: String
    let width: CGFloat = 50
    let height: CGFloat = 50
    let cornerRadius: CGFloat = 10
    let shadowOpacity: Double = 0.3
    let shadowRadius: CGFloat = 5
    let fontSize = FontSize.title
    let color: Color = .white
    
    @ViewBuilder
    var icon: some View {
        if isDefault {
            Image(systemName: categoryIcon)
        } else {
            Text(categoryIcon)
        }
    }
    
    var body: some View {
        icon
            .font(AppFont.customFont(fontSize))
            .foregroundStyle(color)
            .frame(width: width, height: height)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(hex: categoryHexColor))
                    .shadow(
                        color: Color(hex: categoryHexColor)
                            .opacity(shadowOpacity),
                        radius: shadowRadius
                    )
            )
    }
}

struct CategoryNameView: View {
    let name: String
    let fontColor: Color
    let font: CustomFont
    let fontSize: FontSize
    
    // Custom initializer with defaults
    init(name: String, fontColor: Color = .black, font: CustomFont = .bold, fontSize: FontSize = .title3) {
        self.name = name
        self.fontColor = fontColor
        self.font = font
        self.fontSize = fontSize
    }

    var body: some View {
        Text(name)
            .font(AppFont.customFont(font: font, fontSize))
            .foregroundStyle(fontColor)
    }
}

struct AmountTextView: View {
    let amount: Double
    let fontSize: FontSize
    let color: Color
    let font: CustomFont
    
    init(amount: Double, fontSize: FontSize, color: Color, font: CustomFont = .bold) {
        self.amount = amount
        self.fontSize = fontSize
        self.color = color
        self.font = font
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(String(format: "\(Locale.current.currencySymbol ?? "$")%.2f", amount))
        }
        .font(AppFont.customFont(font: font, fontSize))
        .foregroundStyle(color)
    }
}

struct NoExpenseFoundView: View {
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            Text("No expenses found...")
        }
        .font(AppFont.customFont(font: .bold, .title2))
        .padding(.top)
    }
}

