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
    let numItemPerRow = 3
    
    var body: some View {
        ScrollView {
            if !categoryViewModel.customCategories.isEmpty {
                Text("Custom categories")
                    .padding(.top)
                    .font(AppFont.customFont(font: .bold, .title2))
                Grid(horizontalSpacing: 30, verticalSpacing: 30) {
                    let numRows = Int(ceil(Double(categoryViewModel.customCategories.count) / Double(numItemPerRow)))
                    ForEach(0..<numRows, id: \.self) { row in
                        CategoryGridItemView(selectedCategory: $selectedCategory, row: row, defaultItem: false)
                    }
                }
                .padding(.bottom, 20)
                
                Text("Default categories")
                    .font(AppFont.customFont(font: .bold, .title2))
            }
            
            Grid(horizontalSpacing: 30, verticalSpacing: 30) {
                let numRows = Int(ceil(Double(categoryViewModel.defaultCategories.count) / Double(numItemPerRow)))
                ForEach(0..<numRows, id: \.self) { row in
                    CategoryGridItemView(selectedCategory: $selectedCategory, row: row, defaultItem: true)
                }
            }
            .padding()
            .padding(.bottom, 20)
        }
    }
}

struct CategoryGridItemView: View {
    @Binding var selectedCategory: Category?
    let numItemPerRow = 3
    let row: Int
    let defaultItem: Bool
    
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GridRow(alignment: .top) {
            ForEach(0..<numItemPerRow, id: \.self) { column in
                let categories = defaultItem ? categoryViewModel.defaultCategories : categoryViewModel.customCategories
                let index = row * numItemPerRow + column
                
                if index < categories.count {
                    let category = categories[index]
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
        }
        .frame(maxWidth: .infinity)
    }
}
