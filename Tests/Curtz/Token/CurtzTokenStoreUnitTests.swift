//
//  CurtzTokenStoreUnitTests.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 17/04/2023.
//

import XCTest

/*
 1. Store access_token and refresh_token
 2. Delete access_token and refresh_token
 3. Retrieve access_token and refresh_token
 */

enum StoreError: Error {
    case notFound
    case failedToSave
}

protocol Store {
    func add(_ val: String, key: String)
    func search(forKey key: String)
    func update(_ val: String, forKey key: String)
    func deleteValue(key: String)
}

protocol StoreQueryable {
    var query: [String: AnyObject] { get }
}

protocol StoreManager {
    func save(_ val: String, forKey key: String)
    func retrieveValue(forKey key: String)
    func update(_ val: String, forKey key: String)
    func removeValue(forKey key: String)
}

final class CurtzStoreManager: StoreManager {
  
    private let store: Store
    
    init(with store: Store){
        self.store = store
    }
    
    func save(_ val: String, forKey key: String) {
        store.add(val, key: key)
    }
    
    func retrieveValue(forKey key: String) {
        store.search(forKey: key)
    }
    
    func update(_ val: String, forKey key: String) {
        store.update(val, forKey: key)
    }
    
    func removeValue(forKey key: String){
        store.deleteValue(key: key)
    }
}

final class CurtzStoreManagerUnitTests: XCTestCase {
    
    func test_init_doesNOT_performAnyAction() {
        let (_,store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_save_messagesTheStorewith_a_save_action_and_rightData() {
        let (store, sut) = makeSUT()
        
        let key = "some-key"
        let value = "some-value"
        
        store.save(value, forKey: key)
        XCTAssertEqual(sut.messages, [.add(value, key)])
    }
    
    func test_retrieveValue_messagesTheStorewith_a_search_action_and_rightData() {
        let (sut, store) = makeSUT()
        let key = "some-key"
        
        sut.retrieveValue(forKey: key)
        XCTAssertEqual(store.messages, [.search(key)])
    }
    
    func test_update_messagesTheStorewith_a_update_action_and_rightData() {
        let (sut, store) = makeSUT()
        let key = "some-key"
        let val = "some-value"
        
        sut.update(val, forKey: key)
        XCTAssertEqual(store.messages, [.update(val, key)])
    }
    
    func test_delete_messagesTheStorewith_a_delete_action_and_withRightData() {
        let (sut, store) = makeSUT()
        let key = "another-key"
        
        sut.removeValue(forKey: key)
        XCTAssertEqual(store.messages, [.delete(key)])
    }
    
    
    // MARK: - Private
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: StoreManager, store: MockStore) {
        let store = MockStore()
        let sut = CurtzStoreManager(with: store)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private final class MockStore: Store {
        
        private(set) var messages: [StoreAction] = []
        
        func add(_ val: String, key: String) {
            messages.append(.add(val, key))
        }
        
        func search(forKey key: String){
            messages.append(.search(key))
        }
        
        func update(_ val: String, forKey key: String) {
            messages.append(.update(val, key))
        }
        
        func deleteValue(key: String) {
            messages.append(.delete(key))
        }
    }
}

enum StoreAction: Equatable {
    case add(String, String)
    case search(String)
    case update(String, String)
    case delete(String)
}
