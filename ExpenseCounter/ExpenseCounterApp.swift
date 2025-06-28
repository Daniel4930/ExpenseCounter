//
//  ExpenseCounterApp.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import SwiftUI

@main
struct ExpenseCounterApp: App {
    let persistence = PersistenceContainer.shared
    @StateObject var userViewModel = UserViewModel()
    @StateObject var categoryViewModel = CategoryViewModel()
    @StateObject var expenseViewModel = ExpenseViewModel()
    @State private var isLoading = true
    
    var body: some Scene {
        WindowGroup {
            if isLoading {
                ProgressView("Loading...")
                    .onAppear {
                        performCloudKitSync {
                            userViewModel.fetchUser()
                            expenseViewModel.fetchExpensesOfMonthYear()
                            categoryViewModel.ensureDefaultCategoriesExist() {
                                isLoading = false
                            }
                        }
                    }
            } else {
                ContentView()
                    .environmentObject(userViewModel)
                    .environmentObject(categoryViewModel)
                    .environmentObject(expenseViewModel)
                    .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
            }
        }
    }
    func performCloudKitSync(completion: @escaping () -> Void) {
        let didSyncBefore = UserDefaults.standard.bool(forKey: "hasSyncedWithCloudKit")
        if didSyncBefore {
            completion()
            return
        }
        
        var observer: NSObjectProtocol
        observer = NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: persistence.container.persistentStoreCoordinator,
            queue: .main
        ) { _ in
            print("CloudKit sync detected")
            UserDefaults.standard.set(true, forKey: "hasSyncedWithCloudKit")
            completion()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if !UserDefaults.standard.bool(forKey: "hasSyncedWithCloudKit") {
                print("Timeout fallback, assume synced")
                UserDefaults.standard.set(true, forKey: "hasSyncedWithCloudKit")
                completion()
            }
        }
        NotificationCenter.default.removeObserver(observer)
    }
}
