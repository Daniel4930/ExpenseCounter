//
//  CategorySelectionGridView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/16/25.
//

import SwiftUI

struct CategorySelectionGridView: View {
    @Binding var selectedCategory: Category?
    @StateObject private var categoryViewModel = CategoryViewModel()
    let columns = [
        GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(categoryViewModel.categories) {category in
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
                CategoryIconView(category: category)

                CategoryNameView(
                    category: category,
                    fontColor: .primary,
                    font: .body,
                    fontWeight: .regular
                )
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
