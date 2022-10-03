//
//  RegistrationResponseMapper.swift
//  curtz-ios
//
//  Created by George Nyakundi on 28/08/2022.
//

import Foundation

/// Class that understand the HTTPResponse received when registering a user
final class RegistrationMapper {
    
    private struct Item: Decodable {
        let id: String
        let email: String
        let created_at: Date
        let updated_at: Date
        
        var response: RegistrationResponse {
            return RegistrationResponse(id: id, email: email, createdAt: created_at, updatedAt: updated_at)
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) -> RegistrationService.Result{
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard isOK(response), let res = try? decoder.decode(Item.self, from: data) else {
            return .failure(RegistrationService.Error.invalidData)
        }
        return .success(res.response)
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}
