//
//  DashboardView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import SwiftUI

struct DashboardView: View {
    @State private var date: Date = generateDate() ?? Date()
    @State private var showCalendar = false
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var expensesViewModel: ExpenseViewModel
    
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
                        Header(user: userViewModel.user.first!)
                        TotalSpendingView(totalSpending: DashboardView.calculateTotalExpense(expensesViewModel.expenses))
                        MonthNavigatorView(showCalendar: $showCalendar, date: $date)
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
                
                SpendFootnoteView()
                
                ScrollView {
                    CategorySpendingView(date: $date)
                }
            }
        }
    }
}
private extension DashboardView {
    static func calculateTotalExpense(_ expenses: [Expense]) -> Double {
        var total: Double = 0
        for expense in expenses {
            total += expense.amount
        }
        return total
    }
}

private extension DashboardView {
    static func generateDate() -> Date? {
        let now = Date()
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.year, .month], from: now)
        
        if let beginningOfMonth = calendar.date(from: components) {
            return beginningOfMonth
        }
        return nil
    }
}

struct Header: View {
    let user: User
    
    var body: some View {
        HStack {
            HStack {
                Image("\(user.profileIcon ?? "face.smilling.inverse")")
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
                    Text("\(user.firstName ?? "User")")
                    Text("\(user.lastName ?? "")")
                }
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            }
            
            Spacer()
        
            NavigationLink(destination: ExpenseFormView (
                amount: "",
                date: Date(),
                time: Date(),
                note: "",
                navTitle: "Add an expense",
                id: nil
            )) {
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

struct SpendFootnoteView: View {
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text("Spends")
                    .foregroundStyle(Color("CustomGreenColor"))
                Text("Today")
            }
            .font(.title3)
            .fontWeight(.bold)
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
