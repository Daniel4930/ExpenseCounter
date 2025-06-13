//
//  DashboardView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        Header()
    }
}

struct Header: View {
    var body: some View {
        HStack {
            Text("Dashboard")
                .font(.system(size: 25, weight: .bold, design: .default))
            
            Spacer()
            
            Button(action: {
                
            }, label: {
                Text("Add Expense")
            })
            .frame(width: 120, height: 35)
            .background(Color("ButtonColor"))
            .foregroundStyle(.white)
            .clipShape(Capsule())
        }
        .padding()
    }
}
