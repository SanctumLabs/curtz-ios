//
//  CurtzStoreManagerUnitTests.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 17/04/2023.
//

import XCTest
import Curtz


protocol StoreQueryable {
    var query: [String: AnyObject] { get }
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
    
    func test_save_completeSuccessfully_whenStoreCompletesSavingSuccessfully() {
        let (sut, store) = makeSUT()
        let key = "some-key"
        let value = "some-value"
        
        expect(sut, toCompleteWith: .success(()), forVal: value, andKey: key) {
            store.completeAddSuccessfully()
        }
    }
    
    func test_save_doesNOTdeliverResult_when_instance_is_deallocated() {
        let store = StoreSpy()
        var sut: StoreManager? = CurtzStoreManager(with: store)
        let key = "dealloc-key"
        let val = "dealloc-val"
        
        var capturedResults = [StoreManager.SaveResult]()
        sut?.save(val, forKey: key, completion: { capturedResults.append($0)})
        sut = nil
        
        store.completeAddSuccessfully()
        XCTAssert(capturedResults.isEmpty)
    }
    
    func test_retrieveValue_messagesTheStorewith_a_search_action_and_rightData() {
        let (sut, store) = makeSUT()
        let key = "some-key"
        
        sut.retrieveValue(forKey: key) { _ in }
        XCTAssertEqual(store.messages, [.search(key)])
    }
    
    func test_retreiveValue_completeswith_an_error_when_storeCompletesWithAnError() {
        let (sut, store) = makeSUT()
        
        let key = "another-interesting-key"
        
        expect(sut, toCompleteWith: .failure(.notFound), andKey: key) {
            store.completeSearch(withError: .notFound)
        }
    }
    
    func test_retreiveValue_completeswith_an_successfulRetrievedString_when_storeCompletesWithSuccessFetch() {
        let (sut, store) = makeSUT()
        
        let key = "another-interesting-key"
        let val = "retrievedval"
        
        expect(sut, toCompleteWith: .success(val), andKey: key) {
            store.completeSearchSuccessfuly(withValue: val)
        }
    }
    
    func test_retrieveValue_doesNOTdeliverResult_when_instance_is_deallocated() {
        let store = StoreSpy()
        var sut: StoreManager? = CurtzStoreManager(with: store)
        let key = "dealloc-key"
        
        var capturedResults = [StoreManager.RetrieveResult]()
        sut?.retrieveValue(forKey: key, completion: { capturedResults.append($0)})
        sut = nil
        
        store.completeSearch(withError: .notFound)
        XCTAssert(capturedResults.isEmpty)
    }
    
    func test_update_messagesTheStorewith_a_update_action_and_rightData() {
        let (sut, store) = makeSUT()
        let key = "some-key"
        let val = "some-value"
        
        sut.update(val, forKey: key) { _ in }
        XCTAssertEqual(store.messages, [.update(val, key)])
    }
    
    func test_update_completesWith_anError_when_theStoreCompletesWithAnError() {
        let (sut, store) = makeSUT()
        let key = "another-key"
        let value = "another-value"
        
        expect(sut, toCompleteWith: .failure(.failedToUpdate), forValue: value, andKey: key) {
            store.completeUpdate(withError: .failedToUpdate)
        }
    }
    
    func test_update_completesSuccessfully_when_theStoreCompletesSuccessfully() {
        let (sut, store) = makeSUT()
        let key = "another-key"
        let value = "another-value"
        
        expect(sut, toCompleteWith: .success(()), forValue: value, andKey: key) {
            store.completeUpdateSuccessfully()
        }
    }
    
    func test_update_doesNOTdeliverResult_when_instance_is_deallocated() {
        let store = StoreSpy()
        var sut: StoreManager? = CurtzStoreManager(with: store)
        let key = "dealloc-key"
        let value = "dealloc-value"
        
        var capturedResults = [StoreManager.UpdateResult]()
        sut?.update(value, forKey: key, completion: { capturedResults.append($0)})

        sut = nil
        store.completeUpdateSuccessfully()
        XCTAssert(capturedResults.isEmpty)
    }
    
    func test_removeValue_messagesTheStorewith_a_delete_action_and_withRightData() {
        let (sut, store) = makeSUT()
        let key = "another-key"
        
        sut.removeValue(forKey: key) { _ in }
        XCTAssertEqual(store.messages, [.delete(key)])
    }
    
    func test_removeValue_completesWithAnError_when_store_completesWithAnError() {
        let (sut, store) = makeSUT()
        let key = "key-to-delete"
        
        expect(sut, toCompleteWith: .failure(.failedToRemove), forKey: key) {
            store.completeDelete(withError: .failedToDelete)
        }
    }
    
    func test_removeValue_completeSuccessfully_when_storeCompletesSuccessfully() {
        let (sut, store) = makeSUT()
        let key = "another-key-to-delete"
        
        expect(sut, toCompleteWith: .success(()), forKey: key) {
            store.completeDeleteSuccessfully()
        }
    }
    
    func test_removeValue_doesNOTdeliverResult_when_instance_is_deallocated() {
        let store = StoreSpy()
        var sut: StoreManager? = CurtzStoreManager(with: store)
        let key = "dealloc-key"
        
        var capturedResults = [StoreManager.DeleteResult]()
        sut?.removeValue(forKey: key, completion: { capturedResults.append($0) })

        sut = nil
        store.completeDeleteSuccessfully()
        XCTAssert(capturedResults.isEmpty)
    }
    
    // MARK: - Private
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: StoreManager, store: StoreSpy) {
        let store = StoreSpy()
        let sut = CurtzStoreManager(with: store)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(
        _ sut: StoreManager,
        toCompleteWith expectedResult: StoreManager.SaveResult,
        forVal val: String,
        andKey key: String,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ){
         let expectation = expectation(description: "wait for add")
        
        sut.save(val, forKey: key) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
            case (.success(), .success()):
                break
            default:
                XCTFail("Expected result \(expectedResult), received \(receivedResult) instead", file: file, line: line)
            }
            
            expectation.fulfill()
        }
        action()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func expect(
        _ sut: StoreManager,
        toCompleteWith expectedResult: StoreManager.RetrieveResult,
        andKey key: String,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ){
         let expectation = expectation(description: "wait for add")
        
        sut.retrieveValue(forKey: key) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
            case let (.success(receivedString), .success(expectedString)):
                XCTAssertEqual(receivedString, expectedString, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), received \(receivedResult) instead", file: file, line: line)
            }
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func expect(
        _ sut: StoreManager,
        toCompleteWith expectedResult: StoreManager.UpdateResult,
        forValue val: String,
        andKey key: String,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ){
         let expectation = expectation(description: "wait for add")
        
        sut.update(val, forKey: key) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
            case (.success(), .success()):
                break
            default:
                XCTFail("Expected result \(expectedResult), received \(receivedResult) instead", file: file, line: line)
            }
            
            expectation.fulfill()
        }
        action()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func expect(
        _ sut: StoreManager,
        toCompleteWith expectedResult: StoreManager.DeleteResult,
        forKey key: String,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ){
         let expectation = expectation(description: "wait for add")
        
        sut.removeValue(forKey: key) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
            case (.success(), .success()):
                break
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
        private(set) var searchCompletions: [(Store.SearchResult) -> Void] = []
        private(set) var updateCompletions: [(Store.UpdateResult) -> Void] = []
        private(set) var deleteCompletions: [(Store.DeleteResult) -> Void] = []
        
        func add(_ val: String, key: String, completion: @escaping (AddResult) -> Void) {
            messages.append(.add(val, key))
            addCompletions.append(completion)
        }
        
        func search(forKey key: String, completion: @escaping(SearchResult) -> Void) {
            messages.append(.search(key))
            searchCompletions.append(completion)
        }
        
        func update(_ val: String, forKey key: String, completion: @escaping(UpdateResult) -> Void) {
            messages.append(.update(val, key))
            updateCompletions.append(completion)
        }
        
        func deleteValue(key: String, completion: @escaping(DeleteResult) -> Void) {
            messages.append(.delete(key))
            deleteCompletions.append(completion)
        }
        
        
        func completeAdd(withError error: StoreError, at index: Int = 0) {
            addCompletions[index](.failure(error))
        }
        
        func completeAddSuccessfully(at index: Int = 0) {
            addCompletions[index](.success(()))
        }
        
        func completeSearch(withError error: StoreError, at index: Int = 0) {
            searchCompletions[index](.failure(error))
        }
        
        func completeSearchSuccessfuly(withValue value: String, at index: Int = 0) {
            searchCompletions[index](.success(value))
        }
        
        func completeUpdate(withError error: StoreError, at index: Int = 0) {
            updateCompletions[index](.failure(error))
        }
        
        func completeUpdateSuccessfully(at index: Int = 0) {
            updateCompletions[index](.success(()))
        }
        
        func completeDelete(withError error: StoreError, at index: Int = 0) {
            deleteCompletions[index](.failure(error))
        }
        
        func completeDeleteSuccessfully(at index: Int = 0) {
            deleteCompletions[index](.success(()))
        }
    }
}

enum StoreAction: Equatable {
    case add(String, String)
    case search(String)
    case update(String, String)
    case delete(String)
}
