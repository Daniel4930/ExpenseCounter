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
        
        NavigationStack {
            VStack {
                ZStack {
                    LinearGradientBackgroundView()
                    HStack(spacing: 0) {
                        Text("Category")
                            .font(AppFont.customFont(.largeTitle))
                            .foregroundStyle(.white)
                            .padding(.leading)
                        Spacer()
                        NavigationLink(destination:
                            CategoryFormView(
                                navTitle: "Add a new category",
                                id: nil,
                                name: "",
                                color: .yellow,
                                icon: ""
                            )
                        ) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
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
                    VStack(alignment: .leading) {
                        Text("Custom categories")
                            .font(AppFont.customFont(font: .bold, .title2))
                        Grid(horizontalSpacing: 40, verticalSpacing: 40) {
                            let numRows = Int(ceil(Double(categoryViewModel.customCategories.count) / Double(numItemPerRow)))
                            ForEach(0..<numRows, id: \.self) { row in
                                CategoryGridRow(row: row, defaultItem: false)
                            }
                        }
                        .padding(.bottom, 20)
                        
                        Text("Default categories")
                            .font(AppFont.customFont(font: .bold, .title2))
                        Grid(horizontalSpacing: 40, verticalSpacing: 40) {
                            let numRows = Int(ceil(Double(categoryViewModel.defaultCategories.count) / Double(numItemPerRow)))
                            ForEach(0..<numRows, id: \.self) { row in
                                CategoryGridRow(row: row, defaultItem: true)
                            }
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
    let numItemPerRow = 3
    let row: Int
    let defaultItem: Bool
    @State private var showSheet = false
    
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GridRow(alignment: .top) {
            ForEach(0..<numItemPerRow, id: \.self) { column in
                let categories = defaultItem ? categoryViewModel.defaultCategories : categoryViewModel.customCategories
                let index = row * numItemPerRow + column
                if index < categories.count {
                    let category = categories[index]
                    
                    if category.defaultCategory {
                        Button {
                            showSheet = true
                        } label: {
                            categoryView(for: category)
                        }
                        .sheet(isPresented: $showSheet) {
                            defaultCategoryMessage()
                            .presentationDetents([.medium])
                            .padding()
                        }
                    } else {
                        if let id = category.id, let name = category.name, let hexColor = category.colorHex, let icon = category.icon {
                            NavigationLink(
                                destination:
                                    CategoryFormView(
                                        navTitle: "Edit a category",
                                        id: id,
                                        name: name,
                                        color: Color(hex: hexColor),
                                        icon: icon
                                    )
                            ) {
                                categoryView(for: category)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

extension CategoryGridRow {
    func categoryView(for category: Category) -> some View {
        VStack(alignment: .center) {
            CategoryIconView (
                categoryIcon: category.icon ?? ErrorCategory.icon,
                isDefault: category.defaultCategory,
                categoryHexColor: category.colorHex ?? ErrorCategory.colorHex
            )
            CategoryNameView(
                name: category.name ?? ErrorCategory.name,
                fontColor: colorScheme == .dark ? .white : .black
            )
            .lineLimit(1)
            .minimumScaleFactor(0.5)
        }
    }
    
    func defaultCategoryMessage() -> some View {
        VStack {
            Text("The default category can't be deleted or edited.")
                .font(AppFont.customFont(font: .bold, .title3))
                .padding()
            Button("Done") {
                showSheet = false
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("CustomGreenColor"))
        }
    }
}
