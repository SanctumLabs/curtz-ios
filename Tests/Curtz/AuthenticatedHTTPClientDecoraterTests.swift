//
//  AuthenticatedHTTPClientDecoraterTests.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 02/09/2022.
//

import XCTest
import Curtz

struct TokenResponse {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
}

protocol TokenService {
    typealias Result = Swift.Result<String, Error>
    func getToken(completion: @escaping (Result) -> Void)
}

class AuthenticatedHTTPClientDecorater: HTTPClient {
    
    private let decoratee: HTTPClient
    private let service: TokenService
    
    init(decoratee: HTTPClient, service: TokenService) {
        self.decoratee = decoratee
        self.service = service
    }
    
    func perform(request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        service.getToken {[decoratee] tokenResult in
            switch tokenResult {
            case let .success(token):
                var signedRequest = request
                signedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                decoratee.perform(request: signedRequest) { _ in }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

class AuthenticatedHTTPClientDecoraterTests: XCTestCase {
    func test_performRequest_withSuccessfulTokenRequest_signsRequestWithToken() {
        let client = HTTPClientSpy()
        let unsignedRequest = anyURLRequest()
        
        let signedRequest = URLRequest(url: anyUrl()).signed(with: anyToken())
        let tokenService = GetTokenServiceStub(stubbedToken: anyToken())
        let sut = AuthenticatedHTTPClientDecorater(decoratee: client, service: tokenService)
        
        sut.perform(request: unsignedRequest) { _ in }
        
        XCTAssertEqual(client.requestsMade, [signedRequest])
    }
    
    func test_performRequest_withFailedTokenRequest_fails() {
        let client = HTTPClientSpy()
        
        let tokenService = GetTokenServiceStub(stubbedError: anyNSError())
        let sut = AuthenticatedHTTPClientDecorater(decoratee: client, service: tokenService)
        
        var receivedResult: HTTPClient.Result?
        sut.perform(request: anyURLRequest()) { receivedResult = $0 }
        
        XCTAssertEqual(client.requestsMade, [])
        XCTAssertThrowsError(try receivedResult?.get())
    }
    
    
    // MARK: - Helpers
    private class GetTokenServiceStub: TokenService {
      
        private let result: TokenService.Result
        
        init(stubbedToken token: String) {
            self.result = .success(token)
        }
        
        init(stubbedError: Error) {
            self.result = .failure(stubbedError)
        }
        func getToken(completion: @escaping (TokenService.Result) -> Void) {
            completion(result)
        }
    }
}


private extension URLRequest {
    func signed(with token: String) -> URLRequest {
        var request = self
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
