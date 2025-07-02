//
//  ExpenseCounterApp.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import SwiftUI

@main
struct ExpenseCounterApp: App {
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var categoryViewModel = CategoryViewModel()
    @StateObject private var expenseViewModel = ExpenseViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userViewModel)
                .environmentObject(categoryViewModel)
                .environmentObject(expenseViewModel)
                .onAppear {
                    UIApplication.shared.addTapGestureRecognizer()
                }
        }
    }
}
