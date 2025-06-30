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

enum FontSize {
    case custom(CGFloat)
    case largeTitle
    case title
    case title2
    case title3
    case title4
    case body
    case callout
    case subheadline
    case footnote
    case caption
    case caption2

    var value: CGFloat {
        switch self {
        case .custom(let size): return size
        case .largeTitle: return 34
        case .title: return 28
        case .title2: return 22
        case .title3: return 20
        case .title4: return 19
        case .body: return 17
        case .callout: return 16
        case .subheadline: return 15
        case .footnote: return 13
        case .caption: return 12
        case .caption2: return 11
        }
    }
}


enum CustomFont: String {
    case regular = "OpenSans-Regular"
    case bold = "OpenSans-Bold"
    case semibold = "OpenSans-Semibold"
}

struct AppFont {
    static let font: CustomFont = .regular
    
    static func customFont(font: CustomFont = .regular, _ size: FontSize = .body) -> Font {
        .custom(font.rawValue, size: size.value)
    }
}

struct CategoryIconView: View {
    let categoryIcon: String
    let isDefault: Bool
    let categoryHexColor: String
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat = 10
    let shadowOpacity: Double = 0.3
    let shadowRadius: CGFloat = 5
    let fontSize = FontSize.title
    let color: Color = .white
    
    init(categoryIcon: String, isDefault: Bool, categoryHexColor: String, width: CGFloat = 60, height: CGFloat = 60) {
        self.categoryIcon = categoryIcon
        self.isDefault = isDefault
        self.categoryHexColor = categoryHexColor
        self.width = width
        self.height = height
    }
    
    @ViewBuilder
    var icon: some View {
        if isDefault {
            Image(systemName: categoryIcon)
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.6, height: height * 0.6)
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
    init(name: String, fontColor: Color = .black, font: CustomFont = .regular, fontSize: FontSize = .title3) {
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

struct LinearGradientBackgroundView: View {
    let colors: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    
    init(colors: [Color] = [Color("GradientColor1"), Color("GradientColor2")], startPoint: UnitPoint = .topTrailing, endPoint: UnitPoint = .bottomLeading) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
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
            Text("No expenses found")
        }
        .font(AppFont.customFont(font: .bold, .title2))
        .padding(.top)
    }
}

struct CustomTextField<FieldType: FocusableField, Label: View>: View {
    var focusedField: FocusState<FieldType?>.Binding
    @Binding var text: String
    var field: FieldType
    var label: () -> Label
    
    var body: some View {
        TextField(text: $text) {
            label()
        }
        .focused(focusedField, equals: field)
    }
}
