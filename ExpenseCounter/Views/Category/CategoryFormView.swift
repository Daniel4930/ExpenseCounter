//
//  CategoryFormView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/22/25.
//

import SwiftUI

enum CategoryFormField: Hashable, CaseIterable {
    case name
    case icon
}

struct CategoryFormView: View {
    let editMode: Bool
    let isDefault: Bool
    let navTitle: String
    
    @State private var name: String = ""
    @State private var color: Color = .yellow
    @State private var icon: String = ""
    @State private var readyToSubmit: Bool = false
    @FocusState private var focusedField: CategoryFormField?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack {
                CategoryIconView(
                    categoryIcon: icon,
                    isDefault: isDefault,
                    categoryHexColor: color.toHex() ?? ErrorCategory.colorHex
                )
                .padding(.top)
                
                CategoryNameView(name: name)

                CustomSectionView(header: "Name") {
                    HStack {
                        TextField(text: $name) {
                            Text("Enter a name")
                                .foregroundStyle(Color("CustomGrayColor"))
                        }
                        .focused($focusedField, equals: .name)
                        .onChange(of: name) { newValue in
                            readyToSubmit = validInputsBeforeSubmit(name, icon)
                        }
                        
                        Spacer()
                        Image(systemName: "tag")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    .inputFormModifier()
                    .foregroundColor(.black)
                }
                .padding([.leading, .trailing, .top])
                
                CustomSectionView(header: "Color") {
                    HStack {
                        Text("Select a color")
                        Spacer()
                        ColorPicker("", selection: $color)
                            .labelsHidden()
                    }
                    .frame(maxWidth: .infinity)
                    .inputFormModifier()
                    .foregroundColor(.black)
                }
                .padding([.leading, .trailing, .top])
                
                CustomSectionView(header: "Icon") {
                    HStack {
                        TextField(text: $icon) {
                            Text("Enter an emote")
                                .foregroundStyle(Color("CustomGrayColor"))
                        }
                        .onChange(of: name) { newValue in
                            readyToSubmit = validInputsBeforeSubmit(name, icon)
                        }
                        
                        Spacer()
                        Image(systemName: "face.smiling")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    .focused($focusedField, equals: .icon)
                    .inputFormModifier()
                    .foregroundColor(.black)
                }
                .padding([.leading, .trailing, .top])
            }
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color("CustomGreenColor"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .animation(.easeInOut(duration: 0.3), value: focusedField)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Submit")
                            .foregroundColor(.white)
                    }
                    .disabled(!readyToSubmit)
                }
                ToolbarItem(placement: .principal) {
                    Text(navTitle)
                        .foregroundColor(.white)
                        .font(AppFont.customFont(.title2))
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Button {
                        focusedField = switchFocusedState(field: focusedField, direction: 1)
                    } label: {
                        Image(systemName: "chevron.up")
                    }

                    Button {
                        focusedField = switchFocusedState(field: focusedField, direction: -1)
                    } label: {
                        Image(systemName: "chevron.down")
                    }

                    Spacer()

                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
    }
}

private extension CategoryFormView {
    func switchFocusedState(field: CategoryFormField?, direction: Int) -> CategoryFormField? {
        guard let field else { return nil }
        let allCases = CategoryFormField.allCases
        guard var index = allCases.firstIndex(of: field) else { return nil }
        if direction == 1 {
            index -= 1
        } else {
            index += 1
        }
        let size = allCases.count
        if index < 0 {
            index = size - 1
        } else if index >= size {
            index = 0
        }
        return allCases[index]
    }
    func validInputsBeforeSubmit(_ name: String, _ icon: String) -> Bool {
        if !name.isEmpty && !icon.isEmpty {
            return true
        }
        return false
    }
}
