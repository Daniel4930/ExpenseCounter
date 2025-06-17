//
//  CategorySelectionGridView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/16/25.
//

import SwiftUI

struct CategorySelectionGridView: View {
    @Binding var selectedCategory: Category?
    @Environment(\.dismiss) private var dismiss
    let categories = MockData.category
    let columns = [
        GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(categories) {category in
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
                                        .fill(Color(hex: category.color))
                                        .shadow(color: Color(hex: category.color).opacity(0.3), radius: 5)
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
            .padding()
            .padding(.bottom, 20)
        }
    }
}
