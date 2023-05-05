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
    func search()
    func update()
    func delete()
}

/// <#Description#>
protocol StoreManager {
    func save(_ val: String, forKey key: String)
}

final class CurtzStoreManager: StoreManager {
  
    private let store: Store
    
    init(with store: Store){
        self.store = store
    }
    
    func save(_ val: String, forKey key: String) {
        store.add(val, key: key)
    }
    
}

final class CurtzStoreManagerUnitTests: XCTestCase {
    
    func test_init_doesNOT_performAnyAction() {
        let (_,store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_save_messagesTheStore_save_action() {
        let (store, sut) = makeSUT()
        
        let key = "some-key"
        let value = "some-value"
        
        store.save(value, forKey: key)
        XCTAssertEqual(sut.messages, [.add(value, key)])
        
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
        
        func search() {
            messages.append(.search)
        }
        
        func update() {
            messages.append(.update)
        }
        
        func delete() {
            messages.append(.delete)
        }
    }
}

enum StoreAction: Equatable {
    case add(String, String)
    case search
    case update
    case delete
}
