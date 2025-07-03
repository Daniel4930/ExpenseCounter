//
//  CategorySelectionGridView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/16/25.
//

import SwiftUI

struct CategorySelectionGridView: View {
    @Binding var selectedCategory: Category?
    @EnvironmentObject var categoryViewModel: CategoryViewModel
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
        Button {
            selectedCategory = category
            dismiss()
        } label: {
            if let name = category.name, let icon = category.icon, let colorHex = category.colorHex {
                VStack {
                    CategoryIconView(icon: icon, isDefault: category.defaultCategory, hexColor: colorHex)
                    CategoryNameView(name: name, fontColor: .primary, font: .regular, fontSize: .body)
                }
                .padding()
                .overlay {
                    if selectedCategory == category {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("CustomGreenColor"), lineWidth: 2)
                    }
                }
            }
        }
    }
}
