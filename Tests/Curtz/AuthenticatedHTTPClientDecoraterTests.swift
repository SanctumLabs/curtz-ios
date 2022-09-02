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
                decoratee.perform(request: request.signed(with: token), completion: completion)
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
    
    func test_performRequest_withSuccessfulTokenRequest_completesWithDecorateeResult() throws {
        let values = (Data("some data".utf8), httpURLResponse(200))
        let client = HTTPClientSpy()
        let tokenService = GetTokenServiceStub(stubbedToken: anyToken())
        let sut = AuthenticatedHTTPClientDecorater(decoratee: client, service: tokenService)
        
        var receivedResult: HTTPClient.Result?
        sut.perform(request: anyURLRequest()) { receivedResult = $0 }
        client.complete(with: values)
        
        let receivedValues = try XCTUnwrap(receivedResult).get()
        XCTAssertEqual(receivedValues.0, values.0)
        XCTAssertEqual(receivedValues.1, values.1)
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
