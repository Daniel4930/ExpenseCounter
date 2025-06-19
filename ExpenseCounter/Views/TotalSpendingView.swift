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
            spendingSummary
                .frame(maxHeight: .infinity)
            Spacer()
            divider
            Spacer()
            safeToSpendSection
                .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color("CustomGreenColor"), lineWidth: 1)
        )
        .padding(.horizontal)
        .shadow(color: .black.opacity(0.2), radius: 4)
    }

    private var spendingSummary: some View {
        VStack(alignment: .leading) {
            Text("Spends")
                .font(.title2)
                .fontWeight(.semibold)

            HStack(spacing: 3) {
                Text("$")
                Text(totalSpending.formatted(.number.precision(.fractionLength(0...2))))
                    .foregroundStyle(Color("CustomGreenColor"))
            }
            .font(.title)
            .fontWeight(.bold)
        }
        .foregroundStyle(Color("CustomDarkGrayColor"))
        .padding(.leading, 30)
    }

    private var divider: some View {
        Divider()
            .frame(minWidth: 3)
            .overlay(Color("CustomGreenColor"))
            .padding(.vertical)
    }

    private var safeToSpendSection: some View {
        VStack(alignment: .center, spacing: 5) {
            Text("Safe to spend")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(Color("CustomDarkGrayColor"))

            Button("Set Budget", action: {
                // Action here
            })
            .buttonStyle(.borderedProminent)
            .tint(Color("CustomGreenColor"))
        }
        .padding(.trailing, 30)
    }
}
