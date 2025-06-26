//
//  ProfileView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/25/25.
//

import SwiftUI

struct ProfileView: View {
    let defaultFirstName = "User"
    let defaultLastName = ""
    
    @EnvironmentObject var userViewModel: UserViewModel
    var body: some View {
        ZStack {
            LinearGradientBackgroundView()
                .ignoresSafeArea()
            VStack(alignment: .center) {
                HStack {
                    if let data = userViewModel.user?.profileIcon, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .modifier(AvatarModifier(width: 80, height: 80))
                            .padding(.trailing)
                    } else {
                        Image(systemName: "face.smiling.inverse")
                            .resizable()
                            .modifier(AvatarModifier(width: 80, height: 80))
                            .padding(.trailing)
                    }
                    VStack(alignment: .leading) {
                        Text("\(userViewModel.user?.firstName ?? defaultFirstName)")
                        Text("\(userViewModel.user?.lastName ?? defaultLastName)")
                    }
                    .font(AppFont.customFont(.title2))
                    .padding(.trailing, 25)
                    .overlay(alignment: .topTrailing) {
                        NavigationLink(
                            destination:
                                EditProfileFormView(
                                    id: userViewModel.user?.id,
                                    firstName: userViewModel.user?.firstName ?? defaultFirstName,
                                    lastName: userViewModel.user?.lastName ?? defaultLastName,
                                    data: userViewModel.user?.profileIcon
                                )
                        ) {
                            Image(systemName: "pencil.circle.fill")
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .padding(.top)
                
                Spacer()
                
                Button("Log out") {
                    
                }
                .tint(.white)
                .frame(width: 200, height: 50)
                .background{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.red)
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            BackButtonToolbarItem()
        }
    }
}
