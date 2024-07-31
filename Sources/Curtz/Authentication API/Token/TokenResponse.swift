//
//  TokenResponse.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 04/09/2022.
//

import Foundation

public struct TokenResponse {
    public let accessToken: String
    public let refreshToken: String
    public let tokenType: String
    
    public init(accessToken: String, refreshToken: String, tokenType: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
    }
}

public enum TokenResult {
    case success(TokenResponse)
    case failure(Error)
}

public struct TokenResponseMapper {
    public enum Error: Swift.Error {
        case connectivity
        case invalidRefreshToken
        case invalidData
    }
    private struct Item: Decodable {
        let access_token: String
        let refresh_token: String
        let token_type: String
        
        var response: TokenResponse {
            return .init(accessToken: access_token, refreshToken: refresh_token, tokenType: token_type)
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) -> TokenResult {
        let decoder = JSONDecoder()
        
        guard response.isOK() else {
            return .failure(TokenResponseMapper.Error.invalidRefreshToken)
        }
        
        guard let res = try? decoder.decode(Item.self, from: data) else {
            return .failure(TokenResponseMapper.Error.invalidData)
        }
        
        return .success(res.response)
    }
}
