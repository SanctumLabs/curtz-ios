//
//  XCTestCase+StoreManagerSpy.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 12/05/2023.
//

import Foundation

enum StoreManagerMessage {
    case save(String, String)
    case retrieve(String)
    case update(String, String)
    case removeValue(String)
}

class StoreManagerSpy: StoreManager {
    private(set) var messages: [StoreManagerMessage] = []
    
    private(set) var retrieveCompletions =  [ (StoreManager.RetrieveResult) -> Void]()
    
    func save(_ val: String, forKey key: String, completion: @escaping (SaveResult) -> Void) {
        messages.append(.save(val, key))
    }
    
    func retrieveValue(forKey key: String, completion: @escaping (RetrieveResult) -> Void) {
        messages.append(.retrieve(key))
        retrieveCompletions.append(completion)
    }
    
    func update(_ val: String, forKey key: String, completion: @escaping (UpdateResult) -> Void) {
        messages.append(.update(val, key))
    }
    
    func removeValue(forKey key: String, completion: @escaping (DeleteResult) -> Void) {
        messages.append(.removeValue(key))
    }
    
    func completeRetrieve(withError error: StoreManagerError, at index: Int = 0) {
        retrieveCompletions[index](.failure(error))
    }
    
    func completeRetrieveSuccessfully(withVal value: String, at index: Int = 0) {
        retrieveCompletions[index](.success(value))
    }

}
