//
//  RemoteCategoryViewModel.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/29/25.
//
import CoreData

class RemoteCategoryViewModel: ObservableObject {
    @Published var remoteCategories: [RemoteCategory] = []
    let sharedCoreDataInstance = PersistenceContainer.shared
    
    func searchRemoteCategory(_ id: String) -> RemoteCategory? {
        let fetchRequest: NSFetchRequest = RemoteCategory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.fetchLimit = 1
        
        do {
            if let category = try sharedCoreDataInstance.context.fetch(fetchRequest).first {
                return category
            }
        } catch let error {
            fatalError("Can't search for the remote category -> \(error)")
        }
        return nil
    }
    
    func fetchRemoteCategories() {
        let request = NSFetchRequest<RemoteCategory>(entityName: "RemoteCategory")
        
        do {
            let result = try sharedCoreDataInstance.context.fetch(request)
            DispatchQueue.main.async {
                self.remoteCategories = result
            }
        } catch let error {
            print("Couldn't fetch categories from CloudKit. \(error)")
        }
    }
    func addRemoteCategory(_ id: String, _ name: String, _ colorHex: String, _ icon: String, _ isDefault: Bool) {
        let remoteCategory = RemoteCategory(context: sharedCoreDataInstance.context)
        remoteCategory.id = id
        remoteCategory.name = name
        remoteCategory.colorHex = colorHex
        remoteCategory.icon = icon
        remoteCategory.defaultCategory = isDefault
        
        sharedCoreDataInstance.save()
        fetchRemoteCategories()
    }
    func updateRemoteCategory(_ id: String, _ localId: String?, _ name: String, _ colorHex: String, _ icon: String) {
        let request = NSFetchRequest<RemoteCategory>(entityName: "RemoteCategory")
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        
        do {
            if let existedRemoteCategory = try sharedCoreDataInstance.context.fetch(request).first {
                if let localId = localId {
                    existedRemoteCategory.id = localId
                }
                existedRemoteCategory.name = name
                existedRemoteCategory.colorHex = colorHex
                existedRemoteCategory.icon = icon
                sharedCoreDataInstance.save()
                fetchRemoteCategories()
            }
        } catch let error {
            fatalError("Can't update the remote user -> \(error)")
        }
    }
    func deleteRemoteCategory(_ id: String) {
        let searchedCategory = searchRemoteCategory(id)
        
        if let category = searchedCategory {
            sharedCoreDataInstance.context.delete(category)
            sharedCoreDataInstance.save()
            fetchRemoteCategories()
        } else {
            fatalError("Error deleting the remote category")
        }
    }
}
