//
//  UserViewModel.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/17/25.
//

import CoreData

class UserViewModel: ObservableObject {
    @Published var user: User?
    private let sharedCoreDataInstance = PersistenceContainer.shared
    
    func fetchUser() {
        let request = NSFetchRequest<User>(entityName: "User")
        request.fetchLimit = 1
        
        do {
            let result = try sharedCoreDataInstance.context.fetch(request)
            if let firstUser = result.first {
                DispatchQueue.main.async {
                    self.user = firstUser
                }
            }
            
        } catch let error {
            fatalError("Failed to fetch user with error -> \(error.localizedDescription)")
        }
    }
    
    func addUser(_ firstName: String, _ lastName: String?, _ imageData: Data?) {
        let user = User(context: sharedCoreDataInstance.context)
        user.id = UUID()
        user.firstName = firstName
        user.lastName = lastName
        user.avatarData = imageData
        
        sharedCoreDataInstance.save()
        fetchUser()
    }
    func addUserFromRemote(_ id: UUID, _ firstName: String, _ lastName: String, _ imageData: Data?) {
        let user = User(context: sharedCoreDataInstance.context)
        user.id = id
        user.firstName = firstName
        user.lastName = lastName
        user.avatarData = imageData
        
        sharedCoreDataInstance.save()
        fetchUser()
    }
    func updateUser(_ id: UUID, _ firstName: String, _ lastName: String?, _ imageData: Data?) {
        let request = NSFetchRequest<User>(entityName: "User")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            if let existedUser = try sharedCoreDataInstance.context.fetch(request).first {
                existedUser.firstName = firstName
                existedUser.lastName = lastName
                existedUser.avatarData = imageData
                
                sharedCoreDataInstance.save()
                fetchUser()
            }
        } catch let error {
            fatalError("Can't update the user -> \(error.localizedDescription)")
        }
    }
}
