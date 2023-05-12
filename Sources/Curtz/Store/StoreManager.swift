//
//  StoreManager.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 12/05/2023.
//

import Foundation

public protocol StoreManager {
    
    typealias SaveResult = Swift.Result<Void, StoreManagerError>
    typealias RetrieveResult = Swift.Result<String, StoreManagerError>
    typealias UpdateResult = Swift.Result<Void, StoreManagerError>
    typealias DeleteResult = Swift.Result<Void, StoreManagerError>
    
    func save(_ val: String, forKey key: String, completion: @escaping(SaveResult) -> Void)
    func retrieveValue(forKey key: String, completion: @escaping(RetrieveResult) -> Void)
    func update(_ val: String, forKey key: String, completion: @escaping(UpdateResult) -> Void)
    func removeValue(forKey key: String, completion: @escaping(DeleteResult) -> Void)
}


public enum StoreManagerError: Error, Equatable {
  
    case notFound
    case failedToSave
    case failedToUpdate
    case failedToRemove
    case general(Error?)
    
    public static func == (lhs: StoreManagerError, rhs: StoreManagerError) -> Bool {
        switch (lhs, rhs) {
        case let (.general(lhsError as NSError), .general(rhsError as NSError)):
            return lhsError.domain  == rhsError.domain && lhsError.code == rhsError.code
        case let (lhsE as NSError, rhsE as NSError):
            return lhsE.code == rhsE.code && lhsE.domain == rhsE.domain
        default:
            return false
        }
    }
}
