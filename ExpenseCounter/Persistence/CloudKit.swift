//
//  CloudKit.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/27/25.
//

import CloudKit

class CloudKitDatabase {
    static func queryCategoryIds(completion: @escaping ([String]) -> Void) {
        var ckDefaultCategoryIds: [String] = []
        let categoryRecordType = "CD_Category"
        let container = CKContainer.default()
        
        let privateDatabase = container.privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: categoryRecordType, predicate: predicate)
        
        privateDatabase.fetch(withQuery: query) { returnedResult in
            switch returnedResult {
            case .success(let result):
                for record in result.matchResults {
                    switch record.1 {
                    case .success(let ckRecord):
                        if let categoryId =  ckRecord["CD_id"] as? String {
                            ckDefaultCategoryIds.append(categoryId)
                        }
                    case .failure(let error):
                        print("Faild to fetch CK Record with error\n\(error)")
                    }
                }
                completion(ckDefaultCategoryIds)
            case .failure(let error):
                print("Failed to fetch category ids with error\n\(error)")
                completion(ckDefaultCategoryIds)
            }
        }
    }
}
