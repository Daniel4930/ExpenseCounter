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
    let id: UUID?
    
    @State var name: String
    @State var color: Color
    @State var icon: String
    @State private var readyToSubmit: Bool = false
    @FocusState private var focusedField: CategoryFormField?
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                CategoryIconView(
                    categoryIcon: icon,
                    isDefault: false,
                    categoryHexColor: color.toHex() ?? ErrorCategory.colorHex
                )
                .padding(.top)
                
                CategoryNameView(name: name, fontColor: colorScheme == .light ? .black : .white)

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
                    Button("Delete") {
                        categoryViewModel.deleteCategory(id)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding([.leading, .trailing, .top])
                    .tint(.red)
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color("CustomGreenColor"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .animation(.easeInOut(duration: 0.3), value: focusedField)
            .toolbar {
                BackButtonToolbarItem()
                ToolbarItem(placement: .topBarTrailing) {
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
}
