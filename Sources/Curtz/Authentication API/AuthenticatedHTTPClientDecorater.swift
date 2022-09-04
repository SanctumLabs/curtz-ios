//
//  AuthenticatedHTTPClientDecorater.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 04/09/2022.
//

import Foundation
import Curtz


public class AuthenticatedHTTPClientDecorater: HTTPClient {
    
    private let decoratee: HTTPClient
    private let tokenService: TokenService
    private var pendingTokenRequests = [TokenService.GetTokenCompletion]()
    
    public init(decoratee: HTTPClient, tokenService: TokenService) {
        self.decoratee = decoratee
        self.tokenService = tokenService
    }
    
    public func perform(request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        pendingTokenRequests.append { [decoratee] tokenResult in
            switch tokenResult {
            case let .success(token):
                decoratee.perform(request: request.signed(with: token), completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
        
        guard pendingTokenRequests.count == 1 else { return }
        
        tokenService.getToken { [weak self] tokenResult in
            self?.pendingTokenRequests.forEach { $0(tokenResult) }
            self?.pendingTokenRequests = []
        }
    }
}

