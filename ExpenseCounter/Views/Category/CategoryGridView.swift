//
//  CategoryGridView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/22/25.
//

import SwiftUI

struct CategoryGridView: View {
    
    let numItemPerRow = 3
    
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    
    var body: some View {
        let categories = categoryViewModel.categories
        let numRows = (categories.count / numItemPerRow) + (numItemPerRow % 2)
        
        NavigationStack {
            VStack {
                ZStack {
                    LinearGradient(
                        colors: [Color("GradientColor1"), Color("GradientColor2")],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                    HStack(spacing: 0) {
                        Text("Category")
                            .font(AppFont.customFont(.largeTitle))
                            .foregroundStyle(.white)
                            .padding(.leading)
                        Spacer()
                        NavigationLink(destination: CategoryFormView(editMode: false, isDefault: false, navTitle: "Add a category")) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(.white)
                                .padding(.trailing)
                        }
                    }
                    .padding(.top)
                }
                .frame(maxHeight: 150)
                .clipShape(BottomRoundedRectangle(radius: 15))
                .shadow(color: .black, radius: 1)
                
                ScrollView {
                    Grid(horizontalSpacing: 50, verticalSpacing: 50) {
                        ForEach(0..<numRows, id: \.self) { row in
                            CategoryGridRow(numItemPerRow: numItemPerRow, row: row, categories: categories)
                        }
                    }
                    .padding()
                }
                .padding(.top)
            }
            .ignoresSafeArea()
        }
    }
}

struct CategoryGridRow: View {
    let numItemPerRow: Int
    let row: Int
    let categories: [Category]
    
    var body: some View {
        GridRow(alignment: .top) {
            ForEach(0..<numItemPerRow, id: \.self) {column in
                let index = row * numItemPerRow + column
                if index < categories.count {
                    let category = categories[index]
                    VStack {
                        CategoryIconView(
                            categoryIcon: category.icon ?? ErrorCategory.icon,
                            isDefault: category.defaultCategory,
                            categoryHexColor: category.colorHex ?? ErrorCategory.colorHex
                        )
                        CategoryNameView(name: category.name ?? ErrorCategory.name)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
            }
        }
    }
}

//#Preview {
//    CategoryGridView()
//        .environmentObject(CategoryViewModel())
//}
