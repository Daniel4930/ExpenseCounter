//
//  ReportView.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/19/25.
//

import SwiftUI
import Charts

struct Product: Identifiable {
    let id = UUID()
    let title: String
    let revenue: Double
}

struct ReportView: View {
    
    @State private var products: [Product] = [
        .init(title: "Annual", revenue: 0.7),
        .init(title: "Monthly", revenue: 0.2),
        .init(title: "Lifetime", revenue: 0.1)
    ]
    
    @EnvironmentObject private var categoryViewModel: CategoryViewModel
    @EnvironmentObject private var expenseViewModel: ExpenseViewModel
    
    var body: some View {
        VStack {
            ZStack {
                LinearGradientBackgroundView()
                Text("Report")
                    .font(AppFont.customFont(.title2))
            }
            .foregroundStyle(.white)
            .ignoresSafeArea()
            
            Text("Content")
            
//            Chart(categoryViewModel.categories) { category in
//                SectorMark(angle: .value(category.name ?? "Unknow category", total))
//            }
        }
    }
}

//private extension ReportView {
//    static func totalSpendingAtDate(_ expenses: [Expense], _ date: Date) {
//        for expense in expenses {
//            if expense.category ==
//        }
//    }
//}
//
//#Preview {
//    ReportView()
//        .environmentObject(CategoryViewModel())
//        .environmentObject(ExpenseViewModel())
//}
