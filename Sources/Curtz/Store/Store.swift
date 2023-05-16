//
//  Store.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 12/05/2023.
//

import Foundation


public protocol Store {
    typealias AddResult = Swift.Result<Void, StoreError>
    typealias SearchResult = Swift.Result<String, StoreError>
    typealias UpdateResult = Swift.Result<Void, StoreError>
    typealias DeleteResult = Swift.Result<Void, StoreError>
    
    func add(_ val: String, key: String, completion: @escaping(AddResult) -> Void)
    func search(forKey key: String, completion: @escaping(SearchResult) -> Void)
    func update(_ val: String, forKey key: String, completion: @escaping(UpdateResult) -> Void)
    func deleteValue(key: String, completion: @escaping(DeleteResult) -> Void)
}


public enum StoreError: Error, Equatable {
 
    case notFound
    case failedToSave
    case failedToUpdate
    case failedToDelete
    case generic(Error?)
    
    public static func == (lhs: StoreError, rhs: StoreError) -> Bool {
        switch(lhs, rhs) {
        case let(.generic(lhsError as NSError), .generic(rhsError as NSError)):
            return lhsError.domain == rhsError.domain && lhsError.code == rhsError.code
        case let (lhsE as NSError, rhsE as NSError):
            return lhsE.domain == rhsE.domain && lhsE.code == rhsE.code && lhsE.localizedDescription == rhsE.localizedDescription
        default:
            return false
        }
    }
    
}
