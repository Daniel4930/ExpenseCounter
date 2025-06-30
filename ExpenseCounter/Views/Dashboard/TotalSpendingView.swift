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
        HStack(spacing: 0) {
            spendingSummary
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//                .padding(.leading, 30)
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
        VStack(alignment: .center, spacing: 0) {
            Text("Spends")
                .font(AppFont.customFont(font: .semibold, .title2))

            HStack(spacing: 3) {
                Text(Locale.current.currencySymbol ?? "$")
                Text(totalSpending.formatted(.number.precision(.fractionLength(0...2))))
                    .foregroundStyle(Color("CustomGreenColor"))
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .font(AppFont.customFont(font: .bold, .title))
        }
        .foregroundStyle(Color("CustomDarkGrayColor"))
    }

    private var divider: some View {
        Divider()
            .frame(maxHeight: .infinity)
            .frame(maxWidth: 3)
            .overlay(Color("CustomGreenColor"))
            .padding(.vertical)
    }

    private var safeToSpendSection: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Safe to spend")
                .font(AppFont.customFont(font: .semibold, .body))
                .foregroundStyle(Color("CustomDarkGrayColor"))
                .padding(.bottom, 5)
            Button {
                // Action here
            } label: {
                Text("Set Budget")
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("CustomGreenColor"))
        }
        .font(AppFont.customFont(.body))
    }
}
