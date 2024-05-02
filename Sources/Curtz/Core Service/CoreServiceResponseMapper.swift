//
//  CoreServiceResponseMapper.swift
//  Curtz
//
//  Created by George Nyakundi on 20/11/2023.
//

import Foundation


final class CoreServiceResponseMapper {
    
    private struct ShortenItem: Decodable {
        let id: String
        let custom_alias: String
        let original_url: String
        let expires_on: String
        let keywords: [String]
        let user_id: String
        let short_code: String
        let created_at: String
        let updated_at: String
        let hits: Int
        
        var response: ShortenResponseItem {
            return ShortenResponseItem(
                id: id,
                customAlias: custom_alias,
                originalUrl: original_url,
                expiresOn: expires_on,
                keywords: keywords,
                userId: user_id,
                shortCode: short_code,
                createdAt: created_at,
                updatedAt: updated_at,
                hits: hits
            )
        }
    }
    
    private struct ErrorItem: Decodable {
        let error: String
    }
    
    private static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    static func mapShorteningResponse(_ data: Data, from response: HTTPURLResponse) -> CoreService.ShorteningResult {
        
        if response.isBadRequest() {
            let res = try? decoder.decode(ErrorItem.self, from: data)
            return .failure(CoreService.Error.clientError(res?.error ?? ""))
        }
        
        guard response.isOK(), let res = try? decoder.decode(ShortenItem.self, from: data) else {
            return .failure(CoreService.Error.invalidResponse)
        }
        
        return .success(res.response)
    }
    
    static func mapFetchAllResponse(_ data: Data, from response: HTTPURLResponse) -> CoreService.FetchResult {
        if response.isBadRequest() {
            let res = try? decoder.decode(ErrorItem.self, from: data)
            return .failure(CoreService.Error.clientError(res?.error ?? ""))
        }
        
        guard response.isOK(), let res = try?
                decoder.decode([ShortenItem].self, from: data) else {
            return .failure(CoreService.Error.invalidResponse)
        }
        
        return .success(res.map { $0.response })
    }
}

