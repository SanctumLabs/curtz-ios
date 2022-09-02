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

public typealias GetTokenResult = Result<String, Error>
public typealias GetTokenCompletion = (GetTokenResult) -> Void

protocol TokenService {
    func getToken(completion: @escaping GetTokenCompletion)
}

class AuthenticatedHTTPClientDecorater: HTTPClient {
    
    private let decoratee: HTTPClient
    private let service: TokenService
    
    init(decoratee: HTTPClient, service: TokenService) {
        self.decoratee = decoratee
        self.service = service
    }
    
    func perform(request: URLRequest, completion: @escaping (HTTPClientResult) -> Void) {
        service.getToken {[decoratee] tokenResult in
            switch tokenResult {
            case let .success(token):
                var signedRequest = request
                signedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                decoratee.perform(request: signedRequest) { _ in }
            default:
                break
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
    
    // MARK: - Helpers
    private class GetTokenServiceStub: TokenService {
       
        private let token: String
        
        init(stubbedToken token: String) {
            self.token = token
        }
        
        func getToken(completion: @escaping GetTokenCompletion) {
            completion(.success(token))
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
