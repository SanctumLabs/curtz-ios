//
//  ShortenedURL.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 22/07/2024.
//

import Foundation
import Curtz

struct ShortenedURL {
    let id: String
    let alias: String
    let url: String
    let expiresOn: String
    let keywords: [String]
    let shortCode: String
    let createdAt: String
    let hits: Int
}

extension ShortenResponseItem {
    func asShortenedURL() -> ShortenedURL {
        .init(id: self.id, alias: self.customAlias, url: self.originalUrl, expiresOn: self.expiresOn, keywords: self.keywords, shortCode: self.shortCode, createdAt: self.createdAt, hits: self.hits)
    }
}
