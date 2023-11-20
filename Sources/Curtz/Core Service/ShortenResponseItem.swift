//
//  ShortenResponseItem.swift
//  Curtz
//
//  Created by George Nyakundi on 20/11/2023.
//

import Foundation

public struct ShortenResponseItem {
    let id: String
    let customAlias: String
    let originalUrl: String
    let expiresOn: String
    let keywords: [String]
    let userId: String
    let shortCode: String
    let createdAt: String
    let updatedAt: String
    let hits: Int
    
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
