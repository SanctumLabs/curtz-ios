//
//  AuthenticatedHTTPClientDecoraterTests.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 02/09/2022.
//

import XCTest
import Curtz

class AuthenticatedHTTPClientDecoraterTests: XCTestCase {
    func test_performRequest_withSuccessfulTokenRequest_signsRequestWithToken() {
        let client = HTTPClientSpy()
        let unsignedRequest = anyURLRequest()
        
        let signedRequest = URLRequest(url: anyUrl()).signed(with: anyToken())
        let tokenService = GetTokenServiceStub(stubbedToken: anyToken())
        let sut = AuthenticatedHTTPClientDecorater(decoratee: client, tokenService: tokenService)
        
        sut.perform(request: unsignedRequest) { _ in }
        
        XCTAssertEqual(client.requestsMade, [signedRequest])
    }
    
    func test_performRequest_withSuccessfulTokenRequest_completesWithDecorateeResult() throws {
        let values = (Data("some data".utf8), httpURLResponse(200))
        let client = HTTPClientSpy()
        let tokenService = GetTokenServiceStub(stubbedToken: anyToken())
        let sut = AuthenticatedHTTPClientDecorater(decoratee: client, tokenService: tokenService)
        
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
        let sut = AuthenticatedHTTPClientDecorater(decoratee: client, tokenService: tokenService)
        
        var receivedResult: HTTPClient.Result?
        sut.perform(request: anyURLRequest()) { receivedResult = $0 }
        
        XCTAssertEqual(client.requestsMade, [])
        XCTAssertThrowsError(try receivedResult?.get())
    }
    
    func test_performRequest_multipleTimes_reusesRunningTokenRequest() {
        let client = HTTPClientSpy()
        let service = GetTokenServiceSpy()
        let sut = AuthenticatedHTTPClientDecorater(decoratee: client, tokenService: service)
        
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
        let sut = AuthenticatedHTTPClientDecorater(decoratee: client, tokenService: tokenService)
        
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
}
