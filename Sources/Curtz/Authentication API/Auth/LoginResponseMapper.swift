//
//  LoginResponseMapper.swift
//  Curtz
//
//  Created by George Nyakundi on 02/02/2023.
//

import Foundation

public struct LoginMapper {
    
    private struct Item: Decodable {
        let id: String
        let email: String
        let created_at: String
        let updated_at: String
        let access_token: String
        let refresh_token: String
        
        var response: LoginResponse {
            return LoginResponse(id: id, email: email, createdAt: created_at, updatedAt: updated_at, accessToken: access_token, refreshToken: refresh_token)
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) -> AuthService.Result {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard isOK(response), let res = try? decoder.decode(Item.self, from: data) else {
            return .failure(AuthService.Error.invalidData)
        }
        return .success(res.response)
        
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
    
}

