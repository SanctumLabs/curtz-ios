//
//  LoginServiceTests.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 03/10/2022.
//

import XCTest
import Curtz

public class LoginService {
    private let client: HTTPClient
    private let loginURL: URL
    
    public init(loginURL: URL, client: HTTPClient) {
        self.client = client
        self.loginURL = loginURL
    }
    
    public func login(user: LoginRequest) {
        let request = prepareRequest(for: user)
        
        client.perform(request: request) { _ in
           
        }
    }
    
    private func prepareRequest(for user: LoginRequest) -> URLRequest {
        var request = URLRequest(url: self.loginURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: String] = [
            "email": user.email,
            "password": user.password
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        return request
    }
}

final class LoginServiceTests: XCTestCase {
    
    func test_init_doesNOTperformAnyRequest() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestsMade.isEmpty)
    }
    
    func test_login_performsARequest() {
        let (sut, client) = makeSUT()
        
        sut.login(user: testUser())
        XCTAssertFalse(client.requestsMade.isEmpty, "Should make a call atleast")
    }
    
    func test_login_performsRequestWithCorrectInformation() {
        let jsonDecoder = JSONDecoder()
        let (sut, client) = makeSUT()
        let userRequest = LoginRequest(email: "first@email.com", password: "aSeriousLystronsOne")
        sut.login(user: userRequest)
        
        client.requestsMade.forEach { request in
            let receivedLoginRequest = try! jsonDecoder.decode(TestUser.self, from: request.httpBody!)
            XCTAssertEqual(request.httpMethod!, "POST")
            XCTAssertEqual(receivedLoginRequest.email, userRequest.email)
            XCTAssertEqual(receivedLoginRequest.password, userRequest.password)
        }
    }
    
    // MARK: - Helpers
    private func makeSUT( file: StaticString = #filePath, line: UInt = #line) -> (sut: LoginService, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = LoginService(loginURL: testLoginURL(), client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    private func testUser() -> LoginRequest {
        LoginRequest(email: "test@email.com", password: "test-password-long-one")
    }
    
    private func testLoginURL() -> URL {
        URL(string: "https://secure-login.com")!
    }
    
    private struct TestUser: Codable {
        let email: String
        let password: String
    }
}
