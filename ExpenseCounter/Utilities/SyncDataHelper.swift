//
//  SyncDataHelper.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/29/25.
//
import CloudKit

func extractAvatarData(from record: CKRecord) -> Data? {
    if let rawData = record["CD_avatarData"] as? Data {
        return rawData
    }
    
    if let asset = record["CD_avatarData_ckAsset"] as? CKAsset,
       let fileURL = asset.fileURL,
       let assetData = try? Data(contentsOf: fileURL) {
        return assetData
    }
    
    return nil
}

func compareCloudKitDataWithRemoteUserData(_ ckRecords: [CKRecord], _ remoteUserViewModel: RemoteUserViewModel) -> Bool {
    guard let remoteUser = remoteUserViewModel.remoteUser else {
        // No remote user in memory
        return ckRecords.first == nil
    }
    
    // If there's a remote user, make sure there's a CKRecord
    guard let ckRecord = ckRecords.first else {
        return false
    }
    
    // Check ID
    let recordId = ckRecord["CD_id"] as? String
    let remoteId = remoteUser.id?.uuidString
    guard recordId == remoteId else {
        return false
    }
    
    // Check first name
    let recordFirstName = ckRecord["CD_firstName"] as? String
    if recordFirstName != remoteUser.firstName {
        return false
    }
    
    // Check last name
    let recordLastName = ckRecord["CD_lastName"] as? String
    if recordLastName != remoteUser.lastName {
        return false
    }
    
    // Check avatarData (CKAsset)
    let recordAvatarData = extractAvatarData(from: ckRecord)
    if recordAvatarData != remoteUser.avatarData {
        return false
    }
    
    // All fields match
    return true
}

func uploadLocalUserToCloudKit(_ userViewModel: UserViewModel, _ remoteUserViewModel: RemoteUserViewModel) {
    guard let localUser = userViewModel.user,
          let id = localUser.id,
          let firstName = localUser.firstName,
          let lastName = localUser.lastName,
          let imageData = localUser.avatarData else {
        print("No data to upload to CloudKit")
        return
    }
    remoteUserViewModel.addRemoteUser(id, firstName, lastName, imageData)
}

func compareCloudKitDataWithRemoteCategoryData(_ CKRecords: [CKRecord], _ remoteCategoryViewModel: RemoteCategoryViewModel) -> Bool {
    guard CKRecords.count == remoteCategoryViewModel.remoteCategories.count else {
        return false
    }

    for remoteCategory in remoteCategoryViewModel.remoteCategories {
        guard let id = remoteCategory.id else {
            return false
        }

        // Find the *matching* record by ID
        guard let matchingRecord = CKRecords.first(where: { $0["CD_id"] as? String == id }) else {
            return false
        }

        if matchingRecord["CD_name"] as? String != remoteCategory.name { return false }
        if matchingRecord["CD_colorHex"] as? String != remoteCategory.colorHex { return false }
        if matchingRecord["CD_icon"] as? String != remoteCategory.icon { return false }
        if matchingRecord["CD_defaultCategory"] as? Bool != remoteCategory.defaultCategory { return false }
    }

    return true
}


func uploadLocalCategoryToCloudKit(_ categoryViewModel: CategoryViewModel, _ remoteCategoryViewModel: RemoteCategoryViewModel) {
    guard !categoryViewModel.categories.isEmpty else {
        print("No data to upload to CloudKit")
        return
    }
    for category in categoryViewModel.categories {
        if let id = category.id,
           let name = category.name,
           let icon = category.icon,
           let colorHex = category.colorHex
        {
            remoteCategoryViewModel.addRemoteCategory(id, name, colorHex, icon, category.defaultCategory)
        }
    }
}

func syncRemoteUserToLocal(_ remoteUserViewModel: RemoteUserViewModel, _ userViewModel: UserViewModel) {
    guard let remoteUser = remoteUserViewModel.remoteUser,
          let id = remoteUser.id,
          let firstName = remoteUser.firstName,
          let lastName = remoteUser.lastName,
          let imageData = remoteUser.avatarData else {
        print("No remote data to sync")
        return
    }
    
    if let localUser = userViewModel.user, let localId = localUser.id {
        // Local user exists: overwrite local data with CloudKit
        userViewModel.updateUser(localId, id, firstName, lastName, imageData)
    } else {
        // Local user doesn't exist: add from CloudKit
        userViewModel.addUserFromRemote(id, firstName, lastName, imageData)
    }
}
