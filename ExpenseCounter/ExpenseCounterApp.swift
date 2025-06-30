//
//  ExpenseCounterApp.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/13/25.
//

import SwiftUI
import CloudKit

@main
struct ExpenseCounterApp: App {
    let persistence = PersistenceContainer.shared
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var categoryViewModel = CategoryViewModel()
    @StateObject private var expenseViewModel = ExpenseViewModel()
    @StateObject private var remoteUserViewModel = RemoteUserViewModel()
    @StateObject private var remoteCategoryViewModel = RemoteCategoryViewModel()
    
    init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "syncedWithCloudKit") == nil {
            defaults.set(false, forKey: "syncedWithCloudKit")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userViewModel)
                .environmentObject(categoryViewModel)
                .environmentObject(expenseViewModel)
                .environmentObject(remoteUserViewModel)
                .environmentObject(remoteCategoryViewModel)
                .onAppear {
                    UIApplication.shared.addTapGestureRecognizer()
                    performCloudKitSync {
                        print("Syncing CloudKit data with local data completed")
                    }
                }
            }
        }
    
    private func performCloudKitSync(completion: @escaping () -> Void) {
        let isSyncedWithCloudKit = UserDefaults.standard.bool(forKey: "syncedWithCloudKit")
        var syncUserDataComplete = false
        var syncCategoryDataComplete = false
        
        guard isSyncedWithCloudKit else {
            completion()
            return
        }
        
        userViewModel.fetchUser()
        categoryViewModel.fetchCategories()
    
        CloudKitService.sharedInstance.queryCloudKitUserData { result in
            switch result {
            case .failure(let error):
                print("Failed to fetch remote user with an error: \(error)")
                DispatchQueue.main.async {
                    completion()
                }
                
            case .success(let records):
                while !compareCloudKitDataWithRemoteUserData(records, remoteUserViewModel) {
                    self.remoteUserViewModel.fetchRemoteUser()
                }
                
                if self.remoteUserViewModel.remoteUser == nil {
                    uploadLocalUserToCloudKit(userViewModel, remoteUserViewModel)
                } else {
                    syncRemoteUserToLocal(remoteUserViewModel, userViewModel)
                }
                DispatchQueue.main.async {
                    syncUserDataComplete = true
                    if syncUserDataComplete && syncCategoryDataComplete {
                        completion()
                    }
                }
            }
        }
        CloudKitService.sharedInstance.queryCloudKitCategories { result in
            switch result {
            case .failure(let error):
                print("Failed to fetch remote category with an error: \(error)")
            case .success(let records):
                while !compareCloudKitDataWithRemoteCategoryData(records, remoteCategoryViewModel) {
                    self.remoteCategoryViewModel.fetchRemoteCategories()
                }
                self.mergeCategories()
                DispatchQueue.main.async {
                    syncCategoryDataComplete = true
                    if syncUserDataComplete && syncCategoryDataComplete {
                        completion()
                    }
                }
            }
        }
    }
    func mergeCategories() {
        //Remove categories already exist in both CloudKit and local storage
        let localCategoryIds: [String] = categoryViewModel.categories.compactMap { $0.id }
        let remoteCategoryIds: [String] = remoteCategoryViewModel.remoteCategories.compactMap { $0.id }
        
        for id in localCategoryIds {
            guard let category = categoryViewModel.searchCategory(id),
                  let name = category.name,
                  let colorHex = category.colorHex,
                  let icon = category.icon else {
                continue
            }
            // Try to find remote category with same ID
            if let remote = remoteCategoryViewModel.remoteCategories.first(where: { $0.id == id }) {
                // Exists in CloudKit -> check for differences
                if remote.defaultCategory { continue }
                if remote.name != name || remote.colorHex != colorHex || remote.icon != icon {
                    remoteCategoryViewModel.updateRemoteCategory(id, nil, name, colorHex, icon)
                }
            } else {
                // Doesn't exist in CloudKit -> add it
                remoteCategoryViewModel.addRemoteCategory(id, name, colorHex, icon, category.defaultCategory)
            }
        }
        
        for id in remoteCategoryIds {
            guard let category = remoteCategoryViewModel.searchRemoteCategory(id),
                  let name = category.name,
                  let colorHex = category.colorHex,
                  let icon = category.icon else {
                continue
            }
            // Try to find local category with same ID
            if let local = categoryViewModel.categories.first(where: { $0.id == id }) {
                // Exists in local -> check for differences
                if local.defaultCategory { continue }
                if local.name != name || local.colorHex != colorHex || local.icon != icon {
                    categoryViewModel.updateCategory(id, nil, name, colorHex, icon)
                }
            } else {
                // Doesn't exist in local -> add it
                categoryViewModel.addCategory(id, name, colorHex, icon)
            }
        }
    }
}
