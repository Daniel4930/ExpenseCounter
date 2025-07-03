//
//  CategoryFormView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/22/25.
//

import SwiftUI

enum CategoryFormField: FocusableField {
    case name
    case icon
}

//Default categories shouldn't be shown in the form
struct CategoryFormView: View {
    let navTitle: String
    let id: String?
    
    @State var name: String
    @State var color: Color
    @State var icon: String
    @State private var readyToSubmit: Bool = false
    @FocusState private var focusedField: CategoryFormField?
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                if let colorHex = color.toHex() {
                    CategoryIconView(icon: icon, isDefault: false, hexColor: colorHex)
                        .padding(.top)
                }
                
                CategoryNameView(name: name, fontColor: .black)
                    .frame(height: 20)

                CustomSectionView(header: "Name") {
                    HStack {
                        CustomTextField(focusedField: $focusedField, text: $name, field: .name) {
                            Text("Enter a name")
                                .foregroundStyle(Color("CustomGrayColor"))
                        }
                        .onChange(of: name) { newValue in
                            readyToSubmit = validInputsBeforeSubmit(newValue, icon)
                        }
                        
                        Spacer()
                        Image(systemName: "tag")
                            .frame(width: 25, height: 25)
                    }
                    .inputFormModifier()
                    .foregroundColor(.black)
                }
                .padding([.leading, .trailing, .top])

                CustomSectionView(header: "Color") {
                    ColorPicker("", selection: $color)
                        .frame(maxWidth: .infinity)
                        .inputFormModifier(color)
                }
                .padding([.leading, .trailing, .top])
                
                CustomSectionView(header: "Icon") {
                    HStack {
                        CustomTextField(focusedField: $focusedField, text: $icon, field: .icon) {
                            Text("Please enter up to two emojis or characters.")
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .foregroundStyle(Color("CustomGrayColor"))
                        }
                        .onChange(of: icon) { newValue in
                            if !iconInputValid(newValue) && !newValue.isEmpty {
                                icon = String(newValue.dropLast())
                            }
                            readyToSubmit = validInputsBeforeSubmit(name, icon)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "face.smiling")
                            .frame(width: 25, height: 25)
                    }
                    .inputFormModifier()
                    .foregroundColor(.black)
                }
                .padding([.leading, .trailing, .top])
                
                if let id = id {
                    deleteButton(id)
                    .padding([.leading, .trailing, .top])
                }
            }
            .tint(Color("CustomGreenColor"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("CustomGreenColor"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .animation(.easeInOut(duration: 0.3), value: focusedField)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    submitButton()
                }
                NavbarTitle(title: navTitle)
                KeyboardToolbarGroup(focusedField: $focusedField)
            }
            .onAppear {
                readyToSubmit = validInputsBeforeSubmit(name, icon)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

private extension CategoryFormView {
    func iconInputValid(_ icon: String) -> Bool {
        let iconInputPattern = #"^.{1,2}$"#
        if (icon.range(of: iconInputPattern, options: .regularExpression) != nil) {
            return true
        }
        return false
    }
    func validInputsBeforeSubmit(_ name: String, _ icon: String) -> Bool {
        if !name.isEmpty && !icon.isEmpty {
            return true
        }
        return false
    }
    func deleteButton(_ id: String) -> some View {
        Button {
            categoryViewModel.deleteCategory(id)
            dismiss()
        } label: {
            Text("Delete")
                .font(AppFont.customFont(.title3))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .foregroundStyle(.white)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.red)
        )
    }
    func submitButton() -> some View {
        Button {
            if let hexColor = color.toHex() {
                if let id = id {
                    categoryViewModel.updateCategory(id, name, hexColor, icon)
                } else {
                    categoryViewModel.addCategory(name, hexColor, icon)
                }
            }
            dismiss()
        } label: {
            Text("Submit")
                .foregroundColor(readyToSubmit ? .white : Color("CustomGrayColor"))
        }
        .disabled(!readyToSubmit)
    }
}
