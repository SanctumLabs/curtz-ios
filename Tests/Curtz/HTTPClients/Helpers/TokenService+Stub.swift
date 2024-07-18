//
//  File.swift
//  CurtzAllTests
//
//  Created by George Nyakundi on 03/11/2023.
//

import Foundation
import Curtz

final class GetTokenServiceStub: TokenService {
    let getTokenResult: TokenService.GetTokenResult
    let refreshTokenResult: TokenService.RefreshTokenResult
    
    init(stubbedToken token: String) {
        self.getTokenResult = .success(token)
        self.refreshTokenResult = .success(())
    }
    
    init(stubbedError: Error) {
        self.getTokenResult = .failure(stubbedError)
        self.refreshTokenResult = .failure(stubbedError)
    }
    func getToken(completion: @escaping (TokenService.GetTokenResult) -> Void) {
        completion(getTokenResult)
    }
    
    func refreshToken(completion: @escaping RefreshTokenCompletion) {
        completion(refreshTokenResult)
    }
    
}

final class GetTokenServiceSpy: TokenService {
    
    var getTokenCompletions = [(TokenService.GetTokenResult) -> Void]()
    var refreshTokenCompletions = [(TokenService.RefreshTokenResult) -> Void]()
    
    var getTokenCount: Int {
        getTokenCompletions.count
    }
    var refreshTokenCount: Int {
        refreshTokenCompletions.count
    }
    
    func getToken(completion: @escaping (TokenService.GetTokenResult) -> Void) {
        getTokenCompletions.append(completion)
    }
    
    func refreshToken(completion: @escaping RefreshTokenCompletion) {
        refreshTokenCompletions.append(completion)
    }
    
    func completeGetToken(with error: Error, at index: Int = 0) {
        getTokenCompletions[index](.failure(error))
    }
    
    func completeRefreshToken(with error: Error, at index: Int = 0) {
        refreshTokenCompletions[index](.failure(error))
    }
    
    func completeRefreshTokenSuccessfully(at index: Int = 0) {
        refreshTokenCompletions[index](.success(()))
    }
    
    func completeGetTokenSuccessfully(with token: String, at index: Int = 0) {
        getTokenCompletions[index](.success(token))
    }
    
}
