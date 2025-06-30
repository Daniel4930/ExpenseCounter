//
//  ProfileView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/25/25.
//

import SwiftUI
import CloudKit

struct ProfileView: View {
    let defaultFirstName = "User"
    let defaultLastName = "LastName"
    
    @AppStorage("syncedWithCloudKit") var syncWithCloudKit: Bool = false
    @EnvironmentObject var remoteUserViewModel: RemoteUserViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment:.bottom){
                LinearGradientBackgroundView()
                    .ignoresSafeArea()
                HStack {
                    if let data = userViewModel.user?.avatarData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .modifier(AvatarModifier(width: 80, height: 80))
                            .padding(.trailing, 10)
                    } else {
                        Image(systemName: "face.smiling.inverse")
                            .resizable()
                            .modifier(AvatarModifier(width: 80, height: 80))
                            .padding(.trailing, 10)
                    }
                    VStack(alignment: .leading) {
                        Text("\(userViewModel.user?.firstName ?? defaultFirstName)")
                        Text("\(userViewModel.user?.lastName ?? defaultLastName)")
                    }
                    .font(AppFont.customFont(.title2))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .topTrailing) {
                    NavigationLink(
                        destination:
                            EditProfileFormView(
                                id: userViewModel.user?.id,
                                firstName: userViewModel.user?.firstName ?? defaultFirstName,
                                lastName: userViewModel.user?.lastName ?? defaultLastName,
                                data: userViewModel.user?.avatarData
                            )
                    ) {
                        Image(systemName: "pencil.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    }
                }
                .padding(.bottom, 30)
                .padding(.horizontal, 30)
                .foregroundStyle(.white)
            }
            .frame(maxHeight: UIScreen.main.bounds.height * 0.25)
            .clipShape(BottomRoundedRectangle(radius: 15))
            
            List {
                buttonItemView("Support")
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                
                buttonItemView("Feedback")
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                
                buttonItemView("FAQ's")
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                
                HStack(alignment: .center) {
                    Text("Sync with iCloud")
                        .font(AppFont.customFont(font: .semibold, .title3))
                        .foregroundStyle(Color("CustomDarkGrayColor"))
                        .opacity(0.7)
                    Spacer()
                    Toggle("", isOn: $syncWithCloudKit)
                        .labelsHidden()
                        .onChange(of: syncWithCloudKit) { newValue in
                            if newValue {
                                syncToCloudKitData()
                            }
                        }
                }
                .font(AppFont.customFont(.title3))
                .padding()
                .padding(.horizontal    )
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color("CustomGrayColor"))
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                
            }
            .listStyle(.plain)
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .toolbar {
            BackButtonToolbarItem()
            NavbarTitle(title: "Profile")
        }
    }
}

extension ProfileView {
    func buttonItemView(_ label: String) -> some View {
        Button {
            
        } label: {
            HStack(alignment: .center) {
                Text(label)
                    .font(AppFont.customFont(font: .semibold, .title3))
                    .foregroundStyle(Color("CustomDarkGrayColor"))
                    .opacity(0.7)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color("CustomGreenColor"))
            }
            .font(AppFont.customFont(.title3))
            .padding()
            .padding(.horizontal    )
            .overlay(alignment: .bottom) {
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Color("CustomGrayColor"))
            }
        }
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
                        
                    } else if self.userViewModel.user == nil {
                        // Local user doesn't exist: pull from CloudKit
                        self.downloadRemoteUserToLocal()
                        
                    } else {
                        // Both exist: overwrite CloudKit with local
                        self.overwriteCloudKitWithLocal()
                    }
                }
            }
        }
    }
    private func downloadRemoteUserToLocal() {
        guard let remoteUser = remoteUserViewModel.remoteUser,
              let id = remoteUser.id,
              let firstName = remoteUser.firstName,
              let lastName = remoteUser.lastName,
              let imageData = remoteUser.avatarData else {
            print("No remote data to pull")
            return
        }
        userViewModel.addUserFromRemote(id, firstName, lastName, imageData)
    }
    
    private func overwriteCloudKitWithLocal() {
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
