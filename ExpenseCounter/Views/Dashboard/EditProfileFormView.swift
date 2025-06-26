//
//  EditProfileFormView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/25/25.
//

import SwiftUI
import PhotosUI

enum ProfileFormField: FocusableField {
    case firstName
    case lastName
}

struct EditProfileFormView: View {
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var avatar: Image?
    @State private var selectedItem: PhotosPickerItem?
    @State private var readyToSubmit = false
    @FocusState private var focusedField: ProfileFormField?
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    if let image = avatar {
                        image
                            .resizable()
                            .modifier(AvatarModifier(width: 80, height: 80))
                    } else {
                        let color = (colorScheme == .light ? Color.black : Color.white)
                        Text("No avatar")
                            .modifier(AvatarModifier(width: 80, height: 80, gapColor: color, borderColor: color))
                    }
                    
                    VStack(alignment: .leading) {
                        if firstName != "" {
                            Text(firstName)
                        }
                        if lastName != "" {
                            Text(lastName)
                        }
                    }
                }
                
                CustomSectionView(header: "First name") {
                    CustomTextField(focusedField: $focusedField, text: $firstName, field: .firstName) {
                        Text("Enter a first name")
                    }
                    .inputFormModifier()
                }
                CustomSectionView(header: "Last name") {
                    CustomTextField(focusedField: $focusedField, text: $lastName, field: .lastName) {
                        Text("Enter a last name")
                    }
                    .inputFormModifier()
                }
                CustomSectionView(header: "Avatar") {
                    PhotosPicker("Select a photo", selection: $selectedItem, matching: .images)
                        .frame(maxWidth: .infinity)
                        .inputFormModifier()
                        .onChange(of: selectedItem) { newValue in
                            Task {
                                if let load = try? await selectedItem?.loadTransferable(type: Image.self) {
                                    avatar = load
                                } else {
                                    print("Can't load image. Please selects another image")
                                }
                            }
                        }
                }
            }
            .padding()
        }
        .tint(Color("CustomGreenColor"))
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Color("CustomGreenColor"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            BackButtonToolBarItem()
            NavbarTitle(title: "Edit profile")
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text("Submit")
                        .foregroundColor(readyToSubmit ? .white : Color("CustomGrayColor"))
                }
                .disabled(!readyToSubmit)
            }
            KeyboardToolBarGroup(focusedField: $focusedField)
        }
    }
}
