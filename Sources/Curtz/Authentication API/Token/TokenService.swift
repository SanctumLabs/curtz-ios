//
//  TokenService.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 04/09/2022.
//

import Foundation

public protocol TokenService {
    typealias GetTokenResult = Swift.Result<String, Error>
    typealias RefreshTokenResult = Swift.Result<String, Error>
    
    typealias GetTokenCompletion = (GetTokenResult) -> Void
    typealias RefreshTokenCompletion = (RefreshTokenResult) -> Void
    func getToken(completion: @escaping GetTokenCompletion)
    func refreshToken(completion: @escaping RefreshTokenCompletion)
}
