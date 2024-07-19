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
        let (_, _, storeManager) = makeSUT()
        XCTAssertTrue(storeManager.messages.isEmpty)
    }
    
    func test_getToken_sendsARetrieveAccessTokenMessageToTheStore(){
        let (sut, _, storeManager) = makeSUT()
        sut.getToken { _ in }
        XCTAssertEqual(storeManager.messages, [.retrieve("access_token")])
    }
    
    func test_getToken_respondsWithATokenFromTheStore() {
        let (sut, _, storeManager) = makeSUT()
        let token = accessToken()
        expectGetTokenWith(sut, toCompleteWith: .success(token)) {
            storeManager.completeRetrieveSuccessfully(withVal: token)
        }
    }
    
    func test_getToken_respondsWithErrorWhenStoreRespondsWithError() {
        let (sut, _, storeManager) = makeSUT()
        let error: StoreManagerError = .notFound
        
        expectGetTokenWith(sut, toCompleteWith: .failure(error)) {
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
        let (sut, _, storeManager) = makeSUT()
        sut.refreshToken { _ in }
        XCTAssertEqual(storeManager.messages, [.retrieve("refresh_token")])
    }
    
    func test_refreshToken_composesTheCorrectURL() {
        let (sut, client, storeManager) = makeSUT()
        let stored_refresh_token = refreshToken()
        sut.refreshToken { _ in }
        storeManager.completeRetrieveSuccessfully(withVal: stored_refresh_token)
        
        if let urlComponents = URLComponents(url: client.requestsMade[0].url!, resolvingAgainstBaseURL: true) {
            XCTAssertFalse(urlComponents.queryItems!.isEmpty)
        }
    }
    
    func test_refreshToken_completesWithAnErrorIfStoreManagerCompletesWithAnError() {
        let (sut, _, storeManager) = makeSUT()
        let error = Curtz.StoreManagerError.notFound
        expectRefreshToken(sut, toCompleteWith: .failure(error)) {
            storeManager.completeRetrieve(withError: .notFound)
        }
    }
    
    func test_refreshToken_completesWithAnErrorWhenClientCompletesWithAnError() {
        let (sut, client, storeManager) = makeSUT()
        let stored_refresh_token = refreshToken()
        let error = anyNSError()
        
        expectRefreshToken(sut, toCompleteWith: .failure(error)) {
            storeManager.completeRetrieveSuccessfully(withVal: stored_refresh_token)
            client.complete(with: error)
        }
    }
    
    func test_refreshToken_completesSuccessfullyWhenClientCompletesSuccessfully() {
        let (sut, client, storeManager) = makeSUT()
        let stored_refresh_token = refreshToken()
        let new_refresh_token = accessToken()
        let response = makeJSON(jsonFor())
        
        expectRefreshToken(sut, toCompleteWith: .success(new_refresh_token)) {
            storeManager.completeRetrieveSuccessfully(withVal: stored_refresh_token)
            client.complete(withStatusCode: 200, data: response)
        }
    }
    
    func test_refreshToken_completesWithFailureWhenClientCompletesWithWrongStatusCode() {
        let (sut, client, storeManager) = makeSUT()
        let stored_refresh_token = refreshToken()
        let new_refresh_token = accessToken()
        let response = makeJSON(jsonFor())
        
        expectRefreshToken(sut, toCompleteWith: .failure(Curtz.TokenResponseMapper.Error.invalidRefreshToken)) {
            storeManager.completeRetrieveSuccessfully(withVal: stored_refresh_token)
            client.complete(withStatusCode: 400, data: response)
        }
    }
    
    func test_refreshToken_completesSuccessfullyWhenClientCompletesSuccessfullyAndStoreIsUnableToSaveTheToken() {
        let (sut, client, storeManager) = makeSUT()
        let stored_refresh_token = refreshToken()
        let new_refresh_token = accessToken()
        let response = makeJSON(jsonFor())
        
        expectRefreshToken(sut, toCompleteWith: .success(new_refresh_token)) {
            storeManager.completeRetrieveSuccessfully(withVal: stored_refresh_token)
            client.complete(withStatusCode: 200, data: response)
            storeManager.completeSave(withError: .failedToSave, at: 0)
            storeManager.completeSave(withError: .failedToSave, at: 1)
        }
    }
    
    func test_refreshToken_savesBothAccessTokenAndRefreshTokenToTheStoreWhenRefreshingIsSuccessful() {
        let (sut, client, storeManager) = makeSUT()
        let stored_refresh_token = refreshToken()
        let new_refresh_token = accessToken()
        let response = makeJSON(jsonFor())
        
        expectRefreshToken(sut, toCompleteWith: .success(new_refresh_token)) {
            storeManager.completeRetrieveSuccessfully(withVal: stored_refresh_token)
            client.complete(withStatusCode: 200, data: response)
        }
        
        XCTAssertEqual(storeManager.messages, [.retrieve("refresh_token"), .save(accessToken(), "access_token"), .save(refreshToken(), "refresh_token")])
    }
    
    func test_refreshToken_doesNOTResponseAfterInstanceHasBeenDeallocatedForStoreResult() {
        let storeManager = StoreManagerSpy()
        let client = HTTPClientSpy()
        var sut: CurtzTokenService? = CurtzTokenService(storeManager: storeManager, client: client, refreshTokenURL: testTokenURL())
        
        var receivedResult = [TokenService.RefreshTokenResult]()
        
        sut?.refreshToken { receivedResult.append($0)}
        sut = nil
        
        storeManager.completeRetrieve(withError: .notFound)
        XCTAssert(receivedResult.isEmpty)
    }
    
    func test_refreshToken_doesNOTResponseAfterInstanceHasBeenDeallocatedForClientResult() {
        let storeManager = StoreManagerSpy()
        let client = HTTPClientSpy()
        var sut: CurtzTokenService? = CurtzTokenService(storeManager: storeManager, client: client, refreshTokenURL: testTokenURL())
        
        var receivedResult = [TokenService.RefreshTokenResult]()
        
        sut?.refreshToken { receivedResult.append($0)}
        
        storeManager.completeRetrieveSuccessfully(withVal: refreshToken())
        sut = nil
        client.complete(with: anyNSError())
        XCTAssert(receivedResult.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: TokenService, client: HTTPClientSpy, store: StoreManagerSpy){
        let storeManager = StoreManagerSpy()
        let client = HTTPClientSpy()
        let sut = CurtzTokenService(storeManager: storeManager, client: client, refreshTokenURL: testTokenURL())
        
        trackForMemoryLeaks(storeManager, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client, storeManager)
    }
    
    private func expectRefreshToken(_ sut : TokenService, toCompleteWith expectedResult: CurtzTokenService.RefreshTokenResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for refresh token completion")
        sut.refreshToken { receivedResult in
            switch(receivedResult, expectedResult) {
            case let (.success(receivedToken), .success(expectedToken)):
                XCTAssertEqual(receivedToken, expectedToken, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file:file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 0.1)
    }

    
    private func expectGetTokenWith(_ sut: TokenService, toCompleteWith expectedResult: CurtzTokenService.GetTokenResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line ) {
        
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
    
    private func makeJSON(_ res: [String: Any]) -> Data {
        return try! JSONSerialization.data(withJSONObject: res)
    }
    
    private func jsonFor(
        accessToken: String = accessToken(),
        refreshToken: String = refreshToken(),
        token_type: String = "Bearer"
    ) -> [String: String] {
        return [
            "access_token": accessToken,
            "refresh_token": refreshToken,
            "token_type": token_type
        ]
    }
}


