//
//  TotalSpendingView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/15/25.
//

import SwiftUI

struct TotalSpendingView: View {
    var totalSpending: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Spends")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color("FontColor"))
                HStack(spacing: 3) {
                    Text("$")
                        .foregroundStyle(Color("FontColor"))
                        .font(.system(size: 30, weight: .bold))
                    Text("\(totalSpending.formatted(.number.precision(.fractionLength(0...2))))")
                        .foregroundStyle(Color("MainColor"))
                        .font(.system(size: 30, weight: .bold))
                }
            }
            .padding([.top, .bottom, .trailing])
            .padding(.leading, 25)
            
            Spacer()
            
            Divider()
                .frame(minWidth: 3)
                .overlay(Color("MainColor"))
                .padding([.top, .bottom])
            
            Spacer()
            
            VStack(alignment: .center, spacing: 0) {
                Text("Safe to spend")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color("FontColor"))
                    .padding(.bottom, 5)
                Button(action: {
                    
                }, label: {
                    Text("Set Budget")
                })
                .buttonStyle(.borderedProminent)
                .tint(Color("MainColor"))
            }
            .padding([.top, .bottom, .leading])
            .padding(.trailing, 25)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color("BorderColor"), lineWidth: 2)
        )
        .padding([.leading, .trailing])
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
    }
}
