//
//  CurtzTokenServiceUnitTests.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 17/04/2023.
//

import XCTest
import Curtz

final class CurtzTokenServiceUnitTests: XCTestCase {
    
    func test_init_doesNOTPerformAnyRequest() {
        let (_, storeManager) = makeSUT()
        XCTAssertTrue(storeManager.messages.isEmpty)
    }
    
    func test_getToken_sendsARetrieveAccessTokenMessageToTheStore(){
        let (sut, storeManager) = makeSUT()
        sut.getToken { _ in }
        XCTAssertEqual(storeManager.messages, [.retrieve("access_token")])
    }
    
    func test_getToken_respondsWithATokenFromTheStore() {
        let (sut, storeManager) = makeSUT()
        let token = accessToken()
        expect(sut, toCompleteWith: .success(token)) {
            storeManager.completeRetrieveSuccessfully(withVal: token)
        }
    }
    
    func test_getToken_respondsWithErrorWhenStoreRespondsWithError() {
        let (sut, storeManager) = makeSUT()
        let error: StoreManagerError = .notFound
        
        expect(sut, toCompleteWith: .failure(error)) {
            storeManager.completeRetrieve(withError: error)
        }
    }

    func test_getToken_doesNOTRespondAfterSUThasBeenDeallocated() {
        let storeManager = StoreManagerSpy()
        let client = HTTPClientSpy()
        var sut: CurtzTokenService? = CurtzTokenService(storeManager: storeManager, client: client, refreshTokenURL: testTokenURL())
        
        var receivedResult = [TokenService.GetTokenResult]()
        
        sut?.getToken { receivedResult.append($0)}
        sut = nil
        
        storeManager.completeRetrieve(withError: .notFound)
        XCTAssert(receivedResult.isEmpty)
    }
    
    // MARK: Refresh Token
    func test_refreshToken_sendsARetrieveRefreshTokenMessageToTheStore(){
        let (sut, storeManager) = makeSUT()
        sut.refreshToken { _ in }
        XCTAssertEqual(storeManager.messages, [.retrieve("refresh_token")])
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: TokenService, store: StoreManagerSpy){
        let storeManager = StoreManagerSpy()
        let client = HTTPClientSpy()
        let sut = CurtzTokenService(storeManager: storeManager, client: client, refreshTokenURL: testTokenURL())
        
        trackForMemoryLeaks(storeManager, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, storeManager)
    }

    
    private func expect(_ sut: TokenService, toCompleteWith expectedResult: CurtzTokenService.GetTokenResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line ) {
        
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
    
    private func testTokenURL() -> URL {
        URL(string: "https://secure-login.com")!
    }
}


