//
//  ShortenResponseItem.swift
//  Curtz
//
//  Created by George Nyakundi on 20/11/2023.
//

import Foundation

public struct ShortenResponseItem {
    public let id: String
    public let customAlias: String
    public let originalUrl: String
    public let expiresOn: String
    public let keywords: [String]
    public let userId: String
    public let shortCode: String
    public let createdAt: String
    public let updatedAt: String
    public let hits: Int
    
    public init(
        id: String,
        customAlias: String,
        originalUrl: String,
        expiresOn: String,
        keywords: [String],
        userId: String,
        shortCode: String,
        createdAt: String,
        updatedAt: String,
        hits: Int
    ) {
        self.id = id
        self.customAlias = customAlias
        self.originalUrl = originalUrl
        self.expiresOn = expiresOn
        self.keywords = keywords
        self.userId = userId
        self.shortCode = shortCode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.hits = hits
    }
}

extension ShortenResponseItem: Equatable {}
