//
//  ExpenseCounterApp.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import SwiftUI

@main
struct ExpenseCounterApp: App {
    @StateObject var userViewModel = UserViewModel()
    @StateObject var categoryViewModel = CategoryViewModel()
    @StateObject var expenseViewModel = ExpenseViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userViewModel)
                .environmentObject(categoryViewModel)
                .environmentObject(expenseViewModel)
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        }
    }
}
