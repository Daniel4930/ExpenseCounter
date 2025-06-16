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
        _user = State(initialValue: MockData.data)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(
                    colors: [Color("GradientColor1"), Color("GradientColor2")],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(spacing: 0) {
                    Header()
                    TotalSpendingView(totalSpending: 90.81)
                    MonthNavigatorView(showCalendar: $showCalendar, date: $date, dashboardViewModel: dashboardViewModel)
                }
                .padding(.top, 55)
                .overlay(
                    BottomRoundedRectangle(radius: 15)
                        .stroke(Color("BorderColor"), lineWidth: 3)
                )
            }
            .frame(maxHeight: 290)
            .clipShape(BottomRoundedRectangle(radius: 15))
            .shadow(color: .black, radius: 1)
            .ignoresSafeArea()
            
            SpendFootNoteView()

            ScrollView {
                ExpensesView(expenses: $user.expenses)
            }
        }
    }
}

struct Header: View {
    var body: some View {
        HStack {
            Button(action: {
                //TODO: View profile
            }, label: {
                HStack {
                    Image(systemName: "face.smiling")
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
                        Text("Daniel")
                        Text("Le")
                    }
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                }
                Spacer()
                
                AddAnExpenseButtonView()
            })
            .padding([.leading, .trailing, .bottom])
        }
    }
}

struct AddAnExpenseButtonView: View {
    var body: some View {
        Button(action: {
            //TODO: Add a spend
        }, label: {
            Image(systemName: "plus")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 20, maxHeight: 20)
        })
        .foregroundStyle(.white)
    }
}

struct SpendFootNoteView: View {
    var body: some View {
        HStack {
            VStack {
                Text("Spends")
                    .foregroundStyle(Color("MainColor"))
                Text("Today")
            }
            .font(.system(size: 20, weight: .bold))
            .padding(.leading, 30)
            
            Spacer()
            
            Button(action: {
                
            }, label: {
                Text("View all")
            })
            .buttonStyle(.borderedProminent)
            .tint(Color("MainColor"))
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 4)
            .padding(.trailing, 15)
        }
        .padding(.bottom)
        .padding(.top, -50)
    }
}
