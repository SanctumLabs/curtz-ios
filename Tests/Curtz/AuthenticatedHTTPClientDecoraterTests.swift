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
    typealias GetTokenCompletion = (Result) -> Void
    func getToken(completion: @escaping GetTokenCompletion )
}

class AuthenticatedHTTPClientDecorater: HTTPClient {
    
    private let decoratee: HTTPClient
    private let service: TokenService
    private var pendingTokenRequests = [TokenService.GetTokenCompletion]()
    
    init(decoratee: HTTPClient, service: TokenService) {
        self.decoratee = decoratee
        self.service = service
    }
    
    func perform(request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        pendingTokenRequests.append { [decoratee] tokenResult in
            switch tokenResult {
            case let .success(token):
                decoratee.perform(request: request.signed(with: token), completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
        
        guard pendingTokenRequests.count == 1 else { return }
        
        service.getToken { [weak self] tokenResult in
            self?.pendingTokenRequests.forEach { $0(tokenResult) }
            self?.pendingTokenRequests = []
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
    
    func test_performRequest_multipleTimes_reusesRunningTokenRequest() {
        let client = HTTPClientSpy()
        let service = GetTokenServiceSpy()
        let sut = AuthenticatedHTTPClientDecorater(decoratee: client, service: service)
        
        XCTAssertEqual(service.getTokenCount, 0)
        
        sut.perform(request: anyURLRequest()) { _ in }
        sut.perform(request: anyURLRequest()) { _ in }
        
        XCTAssertEqual(service.getTokenCount, 1)
        
        service.complete(with: anyNSError())
        
        sut.perform(request: anyURLRequest()) { _ in }
        
        XCTAssertEqual(service.getTokenCount, 2)
    }
    
    func test_performRequest_multipleTimes_completesWithRespectiveClientDecorateeResult() throws {
        let client = HTTPClientSpy()
        let tokenService = GetTokenServiceSpy()
        let sut = AuthenticatedHTTPClientDecorater(decoratee: client, service: tokenService)
        
        var result1: HTTPClient.Result?
        sut.perform(request: anyURLRequest()) { result1 = $0 }
        
        var result2: HTTPClient.Result?
        sut.perform(request: anyURLRequest()) { result2 = $0 }
        
        tokenService.completeSuccessfully(with: anyToken())
        
        let values = (Data("some data".utf8), httpURLResponse(200))
        client.complete(with: values, at: 0)
        
        let receivedValues = try XCTUnwrap(result1).get()
        XCTAssertEqual(receivedValues.0, values.0)
        XCTAssertEqual(receivedValues.1, values.1)
        
        client.complete(with: anyNSError(), at: 1)
        XCTAssertThrowsError(try result2?.get())
        
        
    }
    
    
    
    // MARK: - Helpers
    private final class GetTokenServiceStub: TokenService {
      
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
    
    private final class GetTokenServiceSpy: TokenService {
        
        var getTokenCompletions = [(TokenService.Result) -> Void]()
        
        var getTokenCount: Int {
            getTokenCompletions.count
        }
        
        func getToken(completion: @escaping (TokenService.Result) -> Void) {
            getTokenCompletions.append(completion)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            getTokenCompletions[index](.failure(error))
        }
        
        func completeSuccessfully(with token: String, at index: Int = 0) {
            getTokenCompletions[index](.success(token))
        }
    }
    
    
}
