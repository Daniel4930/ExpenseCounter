//
//  CategoryFormView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/22/25.
//

import SwiftUI

enum CategoryFormField: Hashable {
    case name
    case color
    case emote
}

struct CategoryFormView: View {
    
    @State private var name: String = "Money"
    @State private var color: Color = .yellow
    @State private var icon: String = ""
    let isDefault: Bool
    @FocusState private var focusedField: CategoryFormField?
    
    let iconName: String = "banknote"
    
    var body: some View {
        ScrollView {
            VStack {
                //Icon Preview
                
                CategoryIconView(
                    categoryIcon: icon,
                    isDefault: isDefault,
                    categoryHexColor: color.toHex() ?? ErrorCategory.colorHex
                )
                CategoryNameView(name: name)
                
                //Name
                CustomSectionView(header: "Name") {
                    HStack {
                        TextField(text: $name) {
                            Text("Enter a name")
                                .foregroundStyle(Color("CustomGrayColor"))
                        }
                        Spacer()
                        Image(systemName: "tag")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    .focused($focusedField, equals: .name)
                    .inputFormModifier()
                    .foregroundColor(.black)
                }
                
                //Color
                CustomSectionView(header: "Color") {
                    HStack {
                        Text("Select a color")
                        Spacer()
                        ColorPicker("", selection: $color)
                            .labelsHidden()
                    }
                    .frame(maxWidth: .infinity)
                    .focused($focusedField, equals: .color)
                    .inputFormModifier()
                    .foregroundColor(.black)
                }
                
                //Icon
                CustomSectionView(header: "Icon") {
                    HStack {
                        TextField(text: $icon) {
                            Text("Enter an emote")
                                .foregroundStyle(Color("CustomGrayColor"))
                        }
                        Spacer()
                        Image(systemName: "face.smiling")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    .focused($focusedField, equals: .emote)
                    .inputFormModifier()
                    .foregroundColor(.black)
                }
            }
        }
    }
}

//#Preview {
//    CategoryFormView()
//}
