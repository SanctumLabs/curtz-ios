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
    func add()
    func search()
    func update()
    func delete()
}

/// <#Description#>
protocol StoreManager {
    
}

final class CurtzStoreManager: StoreManager {
    
    private let store: Store
    
    init(with store: Store){
        self.store = store
    }
}

final class CurtzStoreManagerUnitTests: XCTestCase {
    
    func test_init_doesNOT_performAnyAction() {
        let (_,store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
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
        
        func add() {}
        
        func search() {}
        
        func update() {}
        
        func delete() {}
    }
}

enum StoreAction {
    case add
    case search
    case update
    case delete
}
