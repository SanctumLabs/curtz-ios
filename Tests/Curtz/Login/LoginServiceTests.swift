//
//  LoginServiceTests.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 03/10/2022.
//

import XCTest
import Curtz

public class LoginService {
    let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func login() {
        
    }
}

final class LoginServiceTests: XCTestCase {
    
    func test_init_doesNOTperformAnyRequest() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestsMade.isEmpty)
    }
    
    func test_login_performsRequest_withSomeHTTPBody() {
        let (sut, client) = makeSUT()
        
        sut.login()
        
    }
    
    // MARK: - Helpers
    private func makeSUT( file: StaticString = #filePath, line: UInt = #line) -> (sut: LoginService, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = LoginService(client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    private func testUser() -> LoginRequest {
        
//        let loginRequest = LoginRequest(
        return RegistrationRequest(email: "test@email.com", password: "test-password-long-one")
    }
}
