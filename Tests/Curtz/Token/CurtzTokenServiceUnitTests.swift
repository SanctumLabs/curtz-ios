//
//  CurtzTokenServiceUnitTests.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 17/04/2023.
//

import XCTest
import Curtz


/**
 1. Receive and save the access_token and refresh_token
 2. When a fetch request if made, return the token
 3. If the the token has expired, then use the refresh token to request a new token
 4. Save both the acces_token and refresh_token
 */

class CurtzTokenService: TokenService {
    private let store: Store
    
    init(store: Store) {
        self.store = store
    }
    
    func getToken(completion: @escaping GetTokenCompletion) {
        store.retrieve { [weak self] result in
            
            guard let _ = self else { return }
            
            switch result {
            case let .success(token):
                completion(.success(token))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

final class CurtzTokenServiceUnitTests: XCTestCase {
    
    func test_init_doesNOTPerformAnyRequest() {
        let (_, store) = makeSUT()
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_getToken_sendsARetrieveTokenMessageToTheStore(){
        let (sut, store) = makeSUT()
        sut.getToken { _ in }
        XCTAssertEqual(store.messages, [.retrieveToken])
    }
    
    func test_getToken_respondsWithATokenFromTheStore() {
        let (sut, store) = makeSUT()
        let token = accessToken()
        expect(sut, toCompleteWith: .success(token)) {
            store.completeRetrievalSuccessfully(with: token)
        }
    }
    
    func test_getToken_respondsWithErrorWhenStoreRespondsWithError() {
        let (sut, store) = makeSUT()
        let error: StoreError = .notFound
        
        expect(sut, toCompleteWith: .failure(error)) {
            store.completeRetrieval(with: error)
        }
    }
    
    func test_getToken_doesNOTRespondAfterSUThasBeenDeallocated() {
        let store = CurtzTokenStoreSpy()
        var sut: CurtzTokenService? = CurtzTokenService(store: store)
        
        var receivedResult = [TokenService.Result]()
        
        sut?.getToken { receivedResult.append($0)}
        sut = nil
        
        store.completeRetrieval(with: .notFound)
        XCTAssert(receivedResult.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: TokenService, store: CurtzTokenStoreSpy){
        let store = CurtzTokenStoreSpy()
        let sut = CurtzTokenService(store: store)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    enum ReceivedMessages: Equatable {
        case retrieveToken
    }
    
    private class CurtzTokenStoreSpy: Store {
        private (set) public var messages: [ReceivedMessages] = []
        private (set) public var retrievalCompletions = [RetrievalCompletion]()
        
        func save(_ tokenRequest: SaveTokenRequest, completion: @escaping SaveCompletion) {
        }
        
        func retrieve(completion: @escaping RetrievalCompletion) {
            messages.append(.retrieveToken)
            retrievalCompletions.append(completion)
        }
        
        func completeRetrievalSuccessfully(with token: String, at index:Int = 0) {
            retrievalCompletions[index](.success(token))
        }
        
        func completeRetrieval(with error: StoreError, at index: Int = 0){
            retrievalCompletions[index](.failure(error))
        }
    }
    
    private func expect(_ sut: TokenService, toCompleteWith expectedResult: CurtzTokenService.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line ) {
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.getToken { receivedResult in
            switch(receivedResult, expectedResult) {
            case let (.success(receivedToken), .success(expectedToken)):
                XCTAssertEqual(receivedToken, expectedToken, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 0.1)
    }
}
