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
    let id: UUID?
    @State var firstName: String
    @State var lastName: String
    @State var imageData: Data?
    @State private var avatar: Image?
    @State private var selectedItem: PhotosPickerItem?
    @State private var readyToSubmit = false
    @FocusState private var focusedField: ProfileFormField?
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userViewModel: UserViewModel
    
    init(id: UUID?, firstName: String, lastName: String, data: Data?) {
        self.id = id
        _firstName = State(initialValue: firstName)
        _lastName = State(initialValue: lastName)
        _imageData = State(initialValue: data)
    }
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if avatar != nil {
                    PreviewAvatarView(avatar: $avatar, firstName: $firstName, lastName: $lastName)
                }
                
                CustomSectionView(header: "First name") {
                    CustomTextField(focusedField: $focusedField, text: $firstName, field: .firstName) {
                        Text("Enter a first name")
                    }
                    .inputFormModifier()
                    .onChange(of: firstName) { newValue in
                        readyToSubmit = validateInput(newValue, lastName)
                    }
                }
                CustomSectionView(header: "Last name") {
                    CustomTextField(focusedField: $focusedField, text: $lastName, field: .lastName) {
                        Text("Enter a last name")
                    }
                    .inputFormModifier()
                    .onChange(of: lastName) { newValue in
                        readyToSubmit = validateInput(firstName, newValue)
                    }
                }
                CustomSectionView(header: "Avatar") {
                    PhotosPicker("Select a photo", selection: $selectedItem, matching: .images)
                        .frame(maxWidth: .infinity)
                        .inputFormModifier()
                        .onChange(of: selectedItem) { newValue in
                            Task {
                                if let load = try? await selectedItem?.loadTransferable(type: Data.self) {
                                    imageData = load
                                    if let data = imageData, let uiImage = UIImage(data: data) {
                                        avatar = Image(uiImage: uiImage)
                                    }
                                } else {
                                    print("Can't load image. Please selects another image")
                                }
                            }
                        }
                        .onChange(of: imageData) { newData in
                            if let data = newData, let uiImage = UIImage(data: data) {
                                avatar = Image(uiImage: uiImage)
                            }
                        }
                }
            }
            .padding()
            .onAppear {
                readyToSubmit = validateInput(firstName, lastName)
            }
        }
        .tint(Color("CustomGreenColor"))
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Color("CustomGreenColor"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            BackButtonToolbarItem()
            NavbarTitle(title: "Edit profile")
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if let id = id {
                        userViewModel.updateUser(id, firstName, lastName, imageData)
                    } else {
                        userViewModel.addUser(firstName, lastName, imageData)
                    }
                    dismiss()
                } label: {
                    Text("Submit")
                        .foregroundColor(readyToSubmit ? .white : Color("CustomGrayColor"))
                }
                .disabled(!readyToSubmit)
            }
            KeyboardToolbarGroup(focusedField: $focusedField)
        }
    }
}

extension EditProfileFormView {
    func validateInput(_ firstName: String, _ lastName: String) -> Bool {
        if firstName != "" && lastName != "" {
            return true
        }
        return false
    }
}

struct PreviewAvatarView: View {
    @Binding var avatar: Image?
    @Binding var firstName: String
    @Binding var lastName: String
    
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
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
    }
}
