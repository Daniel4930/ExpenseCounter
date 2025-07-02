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
                if let data = imageData, let uiImage = UIImage(data: data) {
                    PreviewAvatarView(avatar: Image(uiImage: uiImage), firstName: firstName, lastName: lastName)
                }
                
                CustomSectionView(header: "First name") {
                    CustomTextField(focusedField: $focusedField, text: $firstName, field: .firstName) {
                        Text("Enter a first name")
                    }
                    .inputFormModifier()
                    .foregroundStyle(.black)
                    .onChange(of: firstName) { newValue in
                        readyToSubmit = validateInput(newValue)
                    }
                }
                CustomSectionView(header: "Last name") {
                    CustomTextField(focusedField: $focusedField, text: $lastName, field: .lastName) {
                        Text("Enter a last name")
                    }
                    .inputFormModifier()
                    .foregroundStyle(.black)
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
                readyToSubmit = validateInput(firstName)
            }
        }
        .tint(Color("CustomGreenColor"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("CustomGreenColor"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
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
    func validateInput(_ firstName: String) -> Bool {
        if firstName != "" {
            return true
        }
        return false
    }
}

struct PreviewAvatarView: View {
    let avatar: Image?
    let firstName: String
    let lastName: String?

    var body: some View {
        HStack(alignment: .center) {
            if let image = avatar {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .modifier(AvatarModifier(width: 80, height: 80))
            } else {
                Text("No avatar")
                    .modifier(AvatarModifier(width: 80, height: 80, gapColor: .black, borderColor: .black))
            }
            
            VStack(alignment: .leading) {
                if firstName != "" {
                    Text(firstName)
                }
                if let lastName = lastName {
                    Text(lastName)
                }
            }
        }
    }
}
