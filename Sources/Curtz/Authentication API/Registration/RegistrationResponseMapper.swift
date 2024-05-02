//
//  RegistrationResponseMapper.swift
//  curtz-ios
//
//  Created by George Nyakundi on 28/08/2022.
//

import Foundation

/// Class that understand the HTTPResponse received when registering a user
final class RegistrationResponseMapper {
    
    private struct Item: Decodable {
        let id: String
        let email: String
        let created_at: String
        let updated_at: String
        
        var response: RegistrationResponse {
            return RegistrationResponse(id: id, email: email, createdAt: created_at, updatedAt: updated_at)
        }
    }
    
    private struct ErrorItem: Decodable {
        let message: String
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) -> RegistrationService.Result {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if response.isBadRequest() {
            let res = try? decoder.decode(ErrorItem.self, from: data)
            return .failure(RegistrationService.Error.clientError(res?.message ?? ""))
        }
        
        guard response.isOK(), let res = try? decoder.decode(Item.self, from: data) else {
            return .failure(RegistrationService.Error.invalidData)
        }
        return .success(res.response)
    }
   
}
