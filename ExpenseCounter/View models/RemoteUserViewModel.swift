//
//  RemoteUserViewModel.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/28/25.
//

import CoreData

class RemoteUserViewModel: ObservableObject {
    @Published var remoteUser: RemoteUser?
    let sharedCoreDataInstance = PersistenceContainer.shared
    
    func fetchRemoteUser() {
        let request = NSFetchRequest<RemoteUser>(entityName: "RemoteUser")
        request.fetchLimit = 1
        
        do {
            let result = try sharedCoreDataInstance.context.fetch(request)
            if let user = result.first {
                DispatchQueue.main.async {
                    self.remoteUser = user
                }
            }
        } catch let error {
            print("Couldn't fetch remote user from iCloud. \(error)")
        }
    }
    
    func addRemoteUser(_ id: UUID, _ firstName: String, _ lastName: String, _ imageData: Data?) {
        let user = RemoteUser(context: sharedCoreDataInstance.context)
        user.id = id
        user.firstName = firstName
        user.lastName = lastName
        user.avatarData = imageData
        
        sharedCoreDataInstance.save()
    }
    
    func updateRemoteUser(_ id: UUID, _ localId: UUID?, _ firstName: String, _ lastName: String, _ imageData: Data?) {
        let request = NSFetchRequest<RemoteUser>(entityName: "RemoteUser")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            if let existedRemoteUser = try sharedCoreDataInstance.context.fetch(request).first {
                existedRemoteUser.firstName = firstName
                existedRemoteUser.lastName = lastName
                existedRemoteUser.avatarData = imageData
                sharedCoreDataInstance.save()
            }
        } catch let error {
            fatalError("Can't update the remote user -> \(error)")
        }
    }
}
