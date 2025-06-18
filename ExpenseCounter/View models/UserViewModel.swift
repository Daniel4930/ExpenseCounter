//
//  UserViewModel.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/17/25.
//

import CoreData

class UserViewModel: ObservableObject {
    @Published var user: [User] = []
    private let sharedCoreDataInstance = CoreDataStack.shared
    
    init() {
        fetchUser()
    }
    
    func fetchUser() {
        let request = NSFetchRequest<User>(entityName: "User")
        
        do {
            user = try sharedCoreDataInstance.context.fetch(request)
            
            if user.isEmpty {
                createTestUser()
            }
            
        } catch let error {
            fatalError("Failed to fetch user with error -> \(error.localizedDescription)")
        }
    }
    
    func createTestUser() {
        let user = User(context: sharedCoreDataInstance.context)
        user.id = UUID()
        user.firstName = "Daniel"
        user.lastName = "Le"
        user.income = 10000.00
        user.profileIcon = "UserIcon"
        
        sharedCoreDataInstance.save()
        fetchUser()
    }
}
