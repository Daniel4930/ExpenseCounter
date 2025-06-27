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
                        performInitialCloudKitSync { result in
                            userViewModel.fetchUser()
                            categoryViewModel.fetchCategories()
                            if categoryViewModel.defaultCategories.isEmpty {
                                categoryViewModel.addDefaultCategories()
                            }
                            isLoading = result
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
    func performInitialCloudKitSync(completion: @escaping (Bool) -> Void) {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "hasSyncedWithCloudKit")
        guard isFirstLaunch else {
            completion(false)
            return
        }

        // Declare observer as a constant assigned immediately
        let observer = NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: persistence.container.persistentStoreCoordinator,
            queue: .main
        ) { _ in
            print("Remote change observed - assuming initial sync complete")
            UserDefaults.standard.set(true, forKey: "hasSyncedWithCloudKit")
            completion(false)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if !UserDefaults.standard.bool(forKey: "hasSyncedWithCloudKit") {
                print("No sync detected - fallback after 10 seconds")
                UserDefaults.standard.set(true, forKey: "hasSyncedWithCloudKit")
                completion(false)
            }
        }
        NotificationCenter.default.removeObserver(observer)
    }
}
