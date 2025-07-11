//
//  DashboardView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import SwiftUI

struct DashboardView: View {
    @State private var showCalendar = false
    
    @EnvironmentObject var expensesViewModel: ExpenseViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    LinearGradientBackgroundView()
                    
                    VStack(spacing: 0) {
                        Header()
                        TotalSpendingView(totalSpending: calculateTotalExpense())
                        MonthNavigatorView(showCalendar: $showCalendar, date: $expensesViewModel.date)
                    }
                    .padding(.top, 55)
                }
                .frame(maxHeight: UIScreen.main.bounds.height * 0.3)
                .clipShape(BottomRoundedRectangle(radius: 15))
                .shadow(color: .black, radius: 1)
                
                SpendsAndViewAll(date: expensesViewModel.date)
                
                ScrollView {
                    CategorySpendingView(date: expensesViewModel.date)
                }
            }
            .ignoresSafeArea()
        }
        .tint(.white)
        .onAppear {
            expensesViewModel.fetchExpensesOfMonthYear()
            userViewModel.fetchUser()
        }
        .onChange(of: expensesViewModel.date) {newValue in
            expensesViewModel.fetchExpensesOfMonthYear()
        }
    }
}
private extension DashboardView {
    func calculateTotalExpense() -> Double {
        var total: Double = 0
        for expense in expensesViewModel.expensesOfMonth {
            total += expense.amount
        }
        return total
    }
}

struct Header: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .center) {
                NavigationLink(destination: ProfileView()) {
                    if let imageData = userViewModel.user?.avatarData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .modifier(AvatarModifier(width: 60, height: 60))
                    } else {
                        Image(systemName: "face.smiling.inverse")
                            .resizable()
                            .modifier(AvatarModifier(width: 60, height: 60))
                    }
                    VStack(alignment: .leading) {
                        if let user = userViewModel.user, let firstName = user.firstName {
                            Text("\(firstName)")
                            if let lastName = user.lastName {
                                Text("\(lastName)")
                            }
                        } else {
                            Text("User")
                        }
                    }
                    .font(AppFont.customFont(font: .bold, .title3))
                    .foregroundStyle(.white)
                }
            }
            
            Spacer()
        
            NavigationLink(
                destination:
                    ExpenseFormView(navTitle: "Add an expense", id: nil, isEditMode: false)
            ) {
                Image(systemName: "plus")
                    .resizable()
                    .frame(maxWidth: 20, maxHeight: 20)
                    .foregroundStyle(.white)
            }
        }
        .padding([.leading, .trailing, .bottom])
    }
}

struct SpendsAndViewAll: View {
    let date: Date
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text("Spends")
                .foregroundStyle(Color("CustomGreenColor"))
                .font(AppFont.customFont(font: .bold, .title3))
                .padding(.leading, 30)
            
            Spacer()
            
            NavigationLink(destination: AllExpensesView(date: date)) {
                Text("View all")
                    .padding([.leading, .trailing], 5)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("CustomGreenColor"))
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 4)
            .padding(.trailing, 15)
        }
        .font(AppFont.customFont(.title3))
        .padding(.bottom)
        .padding(.top)
    }
}
