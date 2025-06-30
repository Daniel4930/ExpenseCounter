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
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @EnvironmentObject var remoteCategoryViewModel: RemoteCategoryViewModel
    @AppStorage("syncedWithCloudKit") var syncWithCloudKit: Bool = false
    
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
                    Button {
                        categoryViewModel.deleteCategory(id)
                        if syncWithCloudKit {
                            syncToCloudKitData(idToDelete: id)
                        }
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
                    .padding([.leading, .trailing, .top])
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
                                categoryViewModel.updateCategory(id, nil, name, hexColor, icon)
                            } else {
                                categoryViewModel.addCategory(nil, name, hexColor, icon)
                            }
                        }
                        if syncWithCloudKit {
                            syncToCloudKitData(idToDelete: nil)
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
    func syncToCloudKitData(idToDelete: String?) {
        // When the user clicks sync, combine local data with CloudKit, prioritizing local data
        categoryViewModel.fetchCategories()
        
        DispatchQueue.main.async {
            CloudKitService.sharedInstance.queryCloudKitCategories { result in
                switch result {
                case .failure(let error):
                    print("Failed to fetch category ids with error\n\(error)")
                    
                case .success(let records):
                    // Ensure remoteCategory is fetched and consistent with CloudKit
                    while !compareCloudKitDataWithRemoteCategoryData(records, remoteCategoryViewModel) {
                        self.remoteCategoryViewModel.fetchRemoteCategories()
                    }
                    if let id = idToDelete {
                        self.remoteCategoryViewModel.deleteRemoteCategory(id)
                    } else {
                        if self.remoteCategoryViewModel.remoteCategories.isEmpty {
                            // No category data in CloudKit: upload local category data
                            uploadLocalCategoryToCloudKit(categoryViewModel, remoteCategoryViewModel)
                            
                        } else {
                            // overwrite CloudKit with local with what CloudKit doesn't have
                            self.overwriteCloudKitWithLocal()
                        }
                    }
                }
            }
        }
    }
    func overwriteCloudKitWithLocal() {
        for category in categoryViewModel.categories {
            guard let id = category.id,
                  let name = category.name,
                  let colorHex = category.colorHex,
                  let icon = category.icon else {
                continue
            }

            // Try to find remote category with same ID
            if let remote = remoteCategoryViewModel.remoteCategories.first(where: { $0.id == id }) {
                // Exists in CloudKit -> check for differences
                if remote.defaultCategory { continue }
                if remote.name != name || remote.colorHex != colorHex || remote.icon != icon {
                    remoteCategoryViewModel.updateRemoteCategory(id, nil, name, colorHex, icon)
                }
            } else {
                // Doesn't exist in CloudKit -> add it
                remoteCategoryViewModel.addRemoteCategory(id, name, colorHex, icon, category.defaultCategory)
            }
        }
    }
}
