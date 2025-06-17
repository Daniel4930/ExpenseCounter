//
//  DashboardView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import SwiftUI

struct DashboardView: View {
    @State private var date: Date
    @State private var showCalendar = false
    @State private var user: User
    let dashboardViewModel = DashboardViewModel()
    
    init() {
        _date = State(initialValue: dashboardViewModel.generateDate() ?? Date())
        _user = State(initialValue: MockData.mockUser)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    LinearGradient(
                        colors: [Color("GradientColor1"), Color("GradientColor2")],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                    
                    VStack(spacing: 0) {
                        Header(user: user)
                        TotalSpendingView(totalSpending: 90.81)
                        MonthNavigatorView(showCalendar: $showCalendar, date: $date, dashboardViewModel: dashboardViewModel)
                    }
                    .padding(.top, 55)
                    .overlay(
                        BottomRoundedRectangle(radius: 15)
                            .stroke(Color("CustomGreenColor"), lineWidth: 3)
                    )
                }
                .frame(maxHeight: 290)
                .clipShape(BottomRoundedRectangle(radius: 15))
                .shadow(color: .black, radius: 1)
                .ignoresSafeArea()
                
                SpendFootNoteView()
                
                ScrollView {
                    CategoryView()
                }
            }
        }
    }
}

struct Header: View {
    @State var user: User
    
    var body: some View {
        HStack {
            HStack {
                Image("\(user.profileIcon)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .padding(3)
                    .foregroundStyle(.white)
                    .overlay {
                        Circle()
                            .stroke(.white, lineWidth: 2)
                    }
                VStack(alignment: .leading) {
                    Text("\(user.firstName)")
                    Text("\(user.lastName)")
                }
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
            }
            
            Spacer()
        
            NavigationLink(destination: AddExpenseView()) {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 20, maxHeight: 20)
                    .foregroundStyle(.white)
            }
        }
        .padding([.leading, .trailing, .bottom])
    }
}

struct SpendFootNoteView: View {
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text("Spends")
                    .foregroundStyle(Color("CustomGreenColor"))
                Text("Today")
            }
            .font(.system(size: 20, weight: .bold))
            .padding(.leading, 30)
            
            Spacer()
            
            Button(action: {
                
            }, label: {
                Text("View all")
                    .padding([.leading, .trailing], 5)
            })
            .buttonStyle(.borderedProminent)
            .tint(Color("CustomGreenColor"))
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 4)
            .padding(.trailing, 15)
        }
        .padding(.bottom)
        .padding(.top, -50)
    }
}
