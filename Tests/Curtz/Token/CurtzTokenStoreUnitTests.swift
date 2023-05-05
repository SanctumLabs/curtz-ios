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

enum StoreError: Error, Equatable {
    case notFound
    case failedToSave
}

protocol Store {
    typealias AddResult = Swift.Result<Void, StoreError>
    
    func add(_ val: String, key: String, completion: @escaping(AddResult) -> Void)
    func search(forKey key: String)
    func update(_ val: String, forKey key: String)
    func deleteValue(key: String)
}

protocol StoreQueryable {
    var query: [String: AnyObject] { get }
}

enum StoreManagerError: Error, Equatable {
    case notFound
    case failedToSave
}

protocol StoreManager {
    
    typealias SaveResult = Swift.Result<Void, StoreManagerError>
    
    func save(_ val: String, forKey key: String, completion: @escaping(SaveResult) -> Void)
    func retrieveValue(forKey key: String)
    func update(_ val: String, forKey key: String)
    func removeValue(forKey key: String)
}

final class CurtzStoreManager: StoreManager {
   
  
    private let store: Store
    
    init(with store: Store){
        self.store = store
    }
    
    func save(_ val: String, forKey key: String, completion: @escaping (SaveResult) -> Void) {
        store.add(val, key: key) { result  in
            switch result  {
            case let .failure(error):
                switch error {
                case .failedToSave:
                    completion(.failure(.failedToSave))
                case .notFound:
                    completion(.failure(.notFound))
                }
            default:
                break
            }
        }
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
        let (sut, store) = makeSUT()
        
        let key = "some-key"
        let value = "some-value"
        
        sut.save(value, forKey: key) { _ in }
        XCTAssertEqual(store.messages, [.add(value, key)])
    }
    
    func test_save_completesWith_a_failedToSaveError_when_theStoreCompletesWithA_failedToSaveError() {
        let (sut, store) = makeSUT()
        let key = "some-key"
        let value = "some-value"
        
        expect(sut, toCompleteWith: .failure(.failedToSave), forVal: value, andKey: key) {
            store.completeAdd(withError: .failedToSave)
        }
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
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: StoreManager, store: StoreSpy) {
        let store = StoreSpy()
        let sut = CurtzStoreManager(with: store)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: StoreManager, toCompleteWith expectedResult: StoreManager.SaveResult, forVal val: String, andKey key: String, when action: () -> Void, file: StaticString = #file, line: UInt = #line){
         let expectation = expectation(description: "wait for add")
        
        sut.save(val, forKey: key) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), received \(receivedResult) instead", file: file, line: line)
            }
            
            expectation.fulfill()
            
        }
        action()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private final class StoreSpy: Store {
        
        private(set) var messages: [StoreAction] = []
        private(set) var addCompletions: [(Store.AddResult) -> Void] = []
        
        func add(_ val: String, key: String, completion: @escaping (AddResult) -> Void) {
            messages.append(.add(val, key))
            addCompletions.append(completion)
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
        
        func completeAdd(withError error: StoreError, at index: Int = 0) {
            addCompletions[index](.failure(error))
        }
    }
}

enum StoreAction: Equatable {
    case add(String, String)
    case search(String)
    case update(String, String)
    case delete(String)
}
