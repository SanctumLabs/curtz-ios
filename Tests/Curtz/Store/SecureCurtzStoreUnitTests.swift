//
//  SecureCurtzStoreUnitTests.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 12/05/2023.
//

import XCTest
import Security
import Curtz

final class SecureCurtzStoreUnitTests: XCTestCase {
    
    func test_search_shouldReturnANotFoundError_For_ANonExistentKey() {
        let sut = makeSUT()
        let key = "a-weird-key"
        
        sut.search(forKey: key) { result in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error, .notFound)
            default:
                XCTFail("Expected a failure but received something else")
            }
        }
    }
    
    func test_add_shouldPersistInTheStore() {
        let sut = makeSUT()
        let valueToSave = "my-very-strong-password"
        let key = "my-special-key"
        
        let expectation = expectation(description: "wait for save")
        
        sut.add(valueToSave, key: key) { _ in}
        sut.search(forKey: key) { result in
            switch result {
            case let .success(valueRetrieved):
                XCTAssertEqual(valueRetrieved, valueToSave)
            case let .failure(error):
                XCTFail("\(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.3)
    }
    
    func test_update_shouldPersistNewValueIntheStore() {
        let sut = makeSUT()
        let initialValueToSave = "initial-value-to-save"
        let valueToUpdateTo = "heres-the-new value"

        let key = "my-awesome-key"

        let expectationSearch = XCTestExpectation(description: "wait for search")

        // Add
        sut.add(initialValueToSave, key: key) { _ in }
        // Update
        sut.update(valueToUpdateTo, forKey: key) { _ in }
        // Fetch
        sut.search(forKey: key) { result in
            switch result {
            case let .success(retrievedValue):
                XCTAssertNotEqual(retrievedValue, initialValueToSave)
                XCTAssertEqual(retrievedValue, valueToUpdateTo)
            default:
                XCTFail("Update should be successful")
            }
            expectationSearch.fulfill()
        }

        wait(for: [expectationSearch], timeout: 0.9)
    }
    
    func test_update_shouldReturnAnError_when_ItFails() {
        let sut = makeSUT()
        let key = "a-key-that-does-not-exist"
        let val = "nothing"
        let expectation = XCTestExpectation(description: "wait for update")
        
        sut.update(val, forKey: key) { result in
            switch result {
            case let .failure(receivedError):
                XCTAssertEqual(receivedError, .failedToUpdate)
            default:
                XCTFail("Should fail since a value with this key does not exist")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_delete_shouldDeleteARecordFromTheStore() {
        let sut = makeSUT()
        let value = "hatathasdfdafad"
        let key = "a value with a short lifetime"
        
        let firstExpectation = XCTestExpectation(description: "wait for search")
        let secondExpectation = XCTestExpectation(description: "wait for delete")
        
        sut.add(value, key: key) { _ in }
        sut.search(forKey: key) { result in
            switch result  {
            case let .success(retrievedValue):
                XCTAssertEqual(retrievedValue, value)
            default:
                XCTFail("Value should have been saved")
            }
            firstExpectation.fulfill()
        }
        sut.deleteValue(key: key) { _ in }
        sut.search(forKey: key) { result in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error, .notFound)
            default:
                XCTFail("Value should have been deleted")
            }
            secondExpectation.fulfill()
        }
        
        wait(for: [firstExpectation, secondExpectation], timeout: 0.2)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> SecureStore {
        let sut = SecureStore()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
}


// IMPLEMENT SecureStore

final class SecureStore: Store {
    
    init() { /* no code required */}
    
    private let service = "com.sanctumlabs.curtz"
    
    func add(_ val: String, key: String, completion: @escaping (AddResult) -> Void) {

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
    
    func search(forKey key: String, completion: @escaping (SearchResult) -> Void) {
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
    
    func update(_ val: String, forKey key: String, completion: @escaping (UpdateResult) -> Void) {
        
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
    
    func deleteValue(key: String, completion: @escaping (DeleteResult) -> Void) {

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

extension String: LocalizedError {}
