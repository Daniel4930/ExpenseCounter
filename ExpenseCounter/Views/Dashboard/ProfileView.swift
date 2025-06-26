//
//  ProfileView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/25/25.
//

import SwiftUI

struct ProfileView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            LinearGradientBackgroundView()
                .ignoresSafeArea()
            VStack(alignment: .center) {
                HStack {
                    Image(systemName: "face.smiling.inverse")
                        .resizable()
                        .modifier(AvatarModifier(width: 80, height: 80))
                        .padding(.trailing)
                    VStack(alignment: .leading) {
                        Text("Daniel Le")
                        Text(String("daniel@gmail.com"))
                    }
                    .font(AppFont.customFont(.title2))
                    .padding(.trailing)
                    .overlay(alignment: .topTrailing) {
                        NavigationLink(destination: EditProfileFormView()) {
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
            BackButtonToolBarItem()
        }
    }
}

//#Preview {
//    ContentView()
//        .environmentObject(UserViewModel())
//        .environmentObject(ExpenseViewModel())
//        .environmentObject(CategoryViewModel())
//    ProfileView()
//}
