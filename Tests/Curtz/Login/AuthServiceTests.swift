//
//  AuthServiceTests.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 03/10/2022.
//

import XCTest
import Curtz

final class AuthServiceTests: XCTestCase {
    
    func test_init_doesNOTperformAnyRequest() {
        let (_, client, storeManager) = makeSUT()
        XCTAssertTrue(client.requestsMade.isEmpty)
        XCTAssertTrue(storeManager.messages.isEmpty)
    }
    
    func test_login_performsARequest() {
        let (sut, client, _) = makeSUT()
        
        sut.login(user: testUser()){ _ in }
        XCTAssertFalse(client.requestsMade.isEmpty, "Should make a call atleast")
    }
    
    func test_login_performsRequestWithCorrectInformation() {
        let jsonDecoder = JSONDecoder()
        let (sut, client, _) = makeSUT()
        let userRequest = LoginRequest(email: "first@email.com", password: "aSeriousLystronsOne")
        sut.login(user: userRequest) { _ in }
        
        client.requestsMade.forEach { request in
            let receivedLoginRequest = try! jsonDecoder.decode(TestUser.self, from: request.httpBody!)
            XCTAssertEqual(request.httpMethod!, "POST")
            XCTAssertEqual(receivedLoginRequest.email, userRequest.email)
            XCTAssertEqual(receivedLoginRequest.password, userRequest.password)
        }
    }
    
    func test_login_deliversErrorOnClientError() {
        let (sut, client, _) = makeSUT()
        expect(sut, user: testUser(), toCompleteWith: failure(.connectivity), when: {
            let clientError = anyNSError()
            client.complete(with: clientError)
        })
    }
    
    func test_login_deliversErrorOnNON2xxStatusCode() {
        let (sut, client, _) = makeSUT()
        let statusCodes = [199, 300, 301, 400, 500, 503]
        statusCodes.enumerated().forEach { index, code in
            expect(sut, user: testUser(), toCompleteWith: failure(.wrongCredentials), when: {
                let data = errorJSON()
                client.complete(withStatusCode: code, data: data, at: index)
            })
        }
    }
    
    func test_login_deliversLoginResponseOn2xxHTTPResponse() {
        let (sut, client, storeManager) = makeSUT()
        
        let user = testUser()
        let loginResponse = makeLoginResponse(
            id: testID(),
            email: user.email,
            createdAt: (Date(timeIntervalSince1970: 1598627222),"2020-08-28T15:07:02+00:00"),
            updatedAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            accessToken: accessToken(),
            refreshToken: refreshToken()
        )
        
        expect(sut, user: user, toCompleteWith: .success(loginResponse.model), when: {
            let json = makeJSON(loginResponse.json)
            client.complete(withStatusCode: 200, data: json)
        })
        
        XCTAssertEqual(
            storeManager.messages,
            [.save(accessToken(), "access_token"), .save(refreshToken(), "refresh_token")]
        )
    }
    
    func test_login_doesNOTDeliverResultsAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        let storeManager = StoreManagerSpy()
        var capturedResult = [AuthService.Result]()
        
        var sut: AuthService? = AuthService(
            loginURL: testLoginURL(),
            client: client,
            storeManager: storeManager
        )
        sut?.login(user: testUser(), completion: { capturedResult.append($0)})
        sut = nil
        client.complete(withStatusCode: 200, data: makeJSON(jsonFor()))
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
    func test_logout_sendsAdeleteMessageForBoth_accessToken_and_refreshToken_to_storeManager() {
        let (sut, client , storeManager) = makeSUT()
        sut.logout()
        
        XCTAssertTrue(client.requestsMade.isEmpty)
        XCTAssertEqual(
            storeManager.messages,
            [.removeValue("access_token"), .removeValue("refresh_token")]
        )
    }
    
    // MARK: - Helpers
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (
        sut: AuthService,
        client: HTTPClientSpy,
        storeManager: StoreManagerSpy
    ) {
        let client = HTTPClientSpy()
        let storeManager = StoreManagerSpy()
        let sut = AuthService(loginURL: testLoginURL(), client: client, storeManager: storeManager)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(storeManager, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        
        return (sut, client, storeManager)
    }
    
    private func expect(
        _ sut: AuthService,
        user: LoginRequest,
        toCompleteWith expectedResult: AuthService.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for registration completion")
        sut.login(user: user) { receivedResult in
            switch(receivedResult, expectedResult) {
            case let (.success(receivedResponse), .success(expectedResponse)):
                XCTAssertEqual(receivedResponse, expectedResponse, file: file, line: line)
            case let (.failure(receivedError as AuthService.Error), .failure(expectedError as AuthService.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func testUser() -> LoginRequest {
        LoginRequest(email: "test@email.com", password: "test-password-long-one")
    }
    
    private func testLoginURL() -> URL {
        URL(string: "https://secure-login.com")!
    }
    
    private func errorJSON(_ message: String = "") -> Data {
        let json = ["message": message]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func failure(_ error: AuthService.Error) -> AuthService.Result {
        .failure(error)
    }
    
    private struct TestUser: Codable {
        let email: String
        let password: String
    }
    
    private func makeLoginResponse(
        id: String,
        email: String,
        createdAt: (date: Date, iso8601String: String),
        updatedAt: (date: Date, iso8601String: String),
        accessToken: String, refreshToken: String
    ) -> (model: LoginResponse, json: [String: Any]) {
        let model = LoginResponse(
            id: id,
            email: email,
            createdAt: createdAt.iso8601String,
            updatedAt: updatedAt.iso8601String,
            accessToken: accessToken,
            refreshToken: refreshToken
        )
        let json = jsonFor(
            id: id,
            email: email,
            createdAt: createdAt.iso8601String,
            updatedAt: updatedAt.iso8601String,
            accessToken: accessToken,
            refreshToken: refreshToken
        )
        
        return (model, json)
    }
    
    private func makeJSON(_ res: [String: Any]) -> Data {
        return try! JSONSerialization.data(withJSONObject: res)
    }
    
    private func jsonFor(
        id: String = "",
        email: String = "",
        createdAt: String = "",
        updatedAt: String = "",
        accessToken: String = "",
        refreshToken: String = ""
    ) -> [String: String] {
        return [
            "id": id,
            "email": email,
            "created_at": createdAt,
            "updated_at": updatedAt,
            "access_token": accessToken,
            "refresh_token": refreshToken
        ]
    }
    
    private func testID() -> String {
        return "cbujd8eg26udrae2reng"
    }
    
    private func testEmail() -> String {
        return "email@workspace.com"
    }
    
    
}

