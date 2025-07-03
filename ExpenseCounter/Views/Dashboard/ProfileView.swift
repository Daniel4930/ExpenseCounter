//
//  ProfileView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/25/25.
//

import SwiftUI

struct ProfileView: View {
    let defaultFirstName = "User"
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                LinearGradientBackgroundView()
                    .ignoresSafeArea()
                HStack(alignment: .center) {
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
                        if let user = userViewModel.user, let firstName = user.firstName {
                            Text("\(firstName)")
                            if let lastName = user.lastName {
                                Text("\(lastName)")
                            }
                        } else {
                            Text(defaultFirstName)
                        }
                    }
                    .font(AppFont.customFont(.title2))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
            }
            .listStyle(.plain)
        }
        .ignoresSafeArea()
        .toolbar {
            NavbarTitle(title: "Profile")
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    EditProfileFormView(
                        id: userViewModel.user?.id,
                        firstName: userViewModel.user?.firstName ?? defaultFirstName,
                        lastName: userViewModel.user?.lastName ?? "",
                        data: userViewModel.user?.avatarData
                    )
                } label: {
                    Text("Edit")
                        .foregroundStyle(.white)
                }
            }
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
            .padding(.horizontal)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Color("CustomGrayColor"))
            }
        }
    }
}
