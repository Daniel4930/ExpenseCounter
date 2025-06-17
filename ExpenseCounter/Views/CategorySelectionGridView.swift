//
//  CategorySelectionGridView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/16/25.
//

import SwiftUI

struct CategorySelectionGridView: View {
    @Binding var selectedCategory: Category?
    let categories = MockData.mockCategories
    let columns = [
        GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(categories) {category in
                    CategoryGridItemView(selectedCategory: $selectedCategory, category: category)
                }
            }
            .padding()
            .padding(.bottom, 20)
        }
    }
}

struct CategoryGridItemView: View {
    @Binding var selectedCategory: Category?
    @Environment(\.dismiss) private var dismiss
    let category: Category
    
    var body: some View {
        Button(action: {
            selectedCategory = category
            dismiss()
        }, label: {
            VStack {
                Image(systemName: category.icon)
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: category.colorHex))
                            .shadow(color: Color(hex: category.colorHex).opacity(0.3), radius: 5)
                    )
                    .font(.system(size: 28))

                Text(category.name)
            }
            .padding()
            .overlay {
                if selectedCategory == category {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                }
            }
        })
    }
}
