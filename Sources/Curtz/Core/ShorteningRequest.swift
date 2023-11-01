//
//  ShorteningRequest.swift
//  curtz-ios
//
//  Created by George Nyakundi on 27/06/2023.
//

import Foundation

public struct ShorteningRequest {
    public let originalUrl: String
    public let keywords: [String]
    public let expiresOn: String
    
    public init(originalUrl: String, keywords: [String], expiresOn: String) {
        self.originalUrl = originalUrl
        self.keywords = keywords
        self.expiresOn = expiresOn
    }
}

public struct ShorteningResponse: Equatable {
    public let id: String
    public let originalUrl: String
    public let customAlias: String
    public let expiresOn: String
    public let keywords: [String]
    public let shortCode: String
    public let hits: Int
}

public enum ShorteningResult {
    case success(ShorteningResponse)
    case failure(Error)
}
