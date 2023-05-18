//
//  SecureStore.swift
//  curtz-ios
//
//  Created by George Nyakundi on 18/05/2023.
//

import Foundation

public final class SecureStore: Store {
    
    public init() { /* no code required */}
    
    private let service = "com.sanctumlabs.curtz"
    
    public func add(_ val: String, key: String, completion: @escaping (AddResult) -> Void) {

        var query = queryFor(.add)
        query[kSecAttrAccount as String] = key
        query[data] = val.data(using: .utf8) as Any
        // Delete
        SecItemDelete(query as CFDictionary)
        
        // then save
        let status = SecItemAdd(query as CFDictionary, nil)
        
        switch status {
        case errSecSuccess:
            completion(.success(()))
        default:
            completion(.failure(.failedToSave))
        }
    }
    
    public func search(forKey key: String, completion: @escaping (SearchResult) -> Void) {
        var query = queryFor(.search)
        query[kSecAttrAccount as String] = key
        
        var dataTypeRef: AnyObject?
        
        SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        guard let data = dataTypeRef as? Data else {
            completion(.failure(.notFound))
            return
        }
        let str = String(decoding: data, as: UTF8.self)
        if str.isEmpty {
            completion(.failure(.notFound))
        } else {
            completion(.success(str))
        }
    }
    
    public func update(_ val: String, forKey key: String, completion: @escaping (UpdateResult) -> Void) {
        
        var query = queryFor(.update)
        query[kSecAttrAccount as String] =  key as Any
        
        let updateQuery: [String: Any] = [
            kSecAttrAccount as String: key as Any,
            kSecValueData as String: val.data(using: .utf8) as Any
        ]
        
        let status = SecItemUpdate(query as CFDictionary, updateQuery as CFDictionary)
        switch status {
        case errSecSuccess:
            completion(.success(()))
        default:
            completion(.failure(.failedToUpdate))
        }
    }
    
    public func deleteValue(key: String, completion: @escaping (DeleteResult) -> Void) {

        var query = queryFor(.delete)
        query[kSecAttrAccount as String] = key
        
        let status = SecItemDelete(query as CFDictionary)
        
        switch status {
        case errSecSuccess:
            completion(.success(()))
        default:
            completion(.failure(.failedToDelete))
        }
    }
    
    // MARK: - Private Constants
    private let securityClass = kSecClass as String
    private let attributeLabel = kSecAttrLabel as String
    private let serviceName = kSecAttrService as String
    private let shouldReturnData = kSecReturnData as String
    private let matchLimit = kSecMatchLimit as String
    private let matchOnlyOne = kSecMatchLimitOne as String
    private let data = kSecValueData as String
    
    // MARK: - Helper Methods
    func queryFor( _ action: StoreActionType) -> [String: Any] {
        var query: [String: Any] = [:]
        query[serviceName] = service
        query[securityClass] = kSecClassGenericPassword
        
        switch action {
        case .search:
            query[shouldReturnData] = kCFBooleanTrue as Any
            query[kSecMatchLimit as String] = kSecMatchLimitOne
        case .add:
            query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
        default:
            break
        }
        
        return query
    }
    
    enum StoreActionType {
        case add
        case search
        case update
        case delete
    }
    
}
