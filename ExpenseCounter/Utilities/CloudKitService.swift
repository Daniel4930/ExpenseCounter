//
//  CloudKitService.swift
//  ExpenseCounter
//
//  Created by Daniel Le on 6/27/25.
//

import CloudKit

class CloudKitService {
    static let sharedInstance = CloudKitService()
    let container = CKContainer.default()
    
    func queryCloudKitCategories(completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        let recordType = "CD_RemoteCategory"
        
        let privateDatabase = container.privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        var CKCategories: [CKRecord] = []
        
        privateDatabase.fetch(withQuery: query) { returnedResult in
            switch returnedResult {
            case .success(let result):
                for record in result.matchResults {
                    switch record.1 {
                    case .success(let recordData):
                        CKCategories.append(recordData)
                    case .failure(let error):
                        print("CKRecord error \(error)")
                    }
                }
                completion(.success(CKCategories))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func queryCloudKitUserData(completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        let recordType = "CD_RemoteUser"
        
        let privateDatabase = container.privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        var records = [CKRecord]()
        
        privateDatabase.fetch(withQuery: query) { returnedResult in
            switch returnedResult {
            case .success(let result):
                for record in result.matchResults {
                    switch record.1 {
                    case .success(let recordData):
                        records.append(recordData)
                    case .failure(let error):
                        print("CKRecord error \(error)")
                    }
                }
                completion(.success(records))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
