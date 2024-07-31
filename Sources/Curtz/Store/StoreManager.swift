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
    case unknown
}
