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
                        TextField(text: $name) {
                            Text("Enter a name")
                                .foregroundStyle(Color("CustomGrayColor"))
                        }
                        .focused($focusedField, equals: .name)
                        .onChange(of: name) { newValue in
                            readyToSubmit = validInputsBeforeSubmit(newValue, icon)
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
                        Spacer()
                        ColorPicker("", selection: $color)
                            .labelsHidden()
                    }
                    .inputFormModifier(color)
                }
                .padding([.leading, .trailing, .top])
                
                CustomSectionView(header: "Icon") {
                    HStack {
                        TextField(text: $icon) {
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
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    .focused($focusedField, equals: .icon)
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
