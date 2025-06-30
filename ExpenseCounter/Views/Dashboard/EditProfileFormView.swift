//
//  EditProfileFormView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/25/25.
//

import SwiftUI
import PhotosUI
import CloudKit

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
    @EnvironmentObject var remoteUserViewModel: RemoteUserViewModel
    @AppStorage("syncedWithCloudKit") var syncWithCloudKit: Bool = false
    
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
                        readyToSubmit = validateInput(newValue, lastName)
                    }
                }
                CustomSectionView(header: "Last name") {
                    CustomTextField(focusedField: $focusedField, text: $lastName, field: .lastName) {
                        Text("Enter a last name")
                    }
                    .inputFormModifier()
                    .foregroundStyle(.black)
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
                        userViewModel.updateUser(id, nil, firstName, lastName, imageData)
                    } else {
                        userViewModel.addUser(firstName, lastName, imageData)
                    }
                    if syncWithCloudKit {
                        syncToCloudKitData()
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
    func syncToCloudKitData() {
        // When the user clicks sync, combine local data with CloudKit, prioritizing local data
        userViewModel.fetchUser()
        
        DispatchQueue.main.async {
            CloudKitService.sharedInstance.queryCloudKitUserData { result in
                switch result {
                case .failure(let error):
                    print("Failed to fetch remote user with an error: \(error)")
                    
                case .success(let records):
                    // Ensure remoteUser data is fetched and consistent with CloudKit
                    while !compareCloudKitDataWithRemoteUserData(records, remoteUserViewModel) {
                        self.remoteUserViewModel.fetchRemoteUser()
                    }
                    if self.remoteUserViewModel.remoteUser == nil {
                        // No user data in CloudKit: upload local user data
                        uploadLocalUserToCloudKit(userViewModel, remoteUserViewModel)
                        
                    } else {
                        // overwrite CloudKit with local
                        self.overwriteCloudKitWithLocal()
                    }
                }
            }
        }
    }
    func overwriteCloudKitWithLocal() {
        guard let localUser = userViewModel.user,
              let id = localUser.id,
              let firstName = localUser.firstName,
              let lastName = localUser.lastName,
              let imageData = localUser.avatarData,
              let remoteUser = remoteUserViewModel.remoteUser,
              let remoteId = remoteUser.id else {
            print("Cannot overwrite CloudKit without complete local and remote data")
            return
        }
        remoteUserViewModel.updateRemoteUser(remoteId, id, firstName, lastName, imageData)
    }
}

struct PreviewAvatarView: View {
    let avatar: Image?
    let firstName: String
    let lastName: String
    
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        HStack {
            if let image = avatar {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
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
