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
    func getToken(completion: @escaping GetTokenCompletion) {
        
    }
}

final class CurtzTokenServiceUnitTests: XCTestCase {
    
    func test_init_doesNOTPerformAnyRequest() {
        let (_, store) = makeSUT()
        XCTAssert(store.messages.isEmpty)
    }
    
    

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: TokenService, store: CurtzTokenStoreSpy){
        let store = CurtzTokenStoreSpy()
        let sut = CurtzTokenService()
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private class CurtzTokenStoreSpy: TokenStore {
        private (set) public var messages: [SaveTokenRequest] = []
        
        func save(_ tokenRequest: SaveTokenRequest, completion: @escaping SaveCompletion) {
                    
        }
        
        func retrieve(completion: @escaping RetrievalCompletion) {
            
        }
    }
}
