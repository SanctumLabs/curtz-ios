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
