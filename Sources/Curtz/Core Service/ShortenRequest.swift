//
//  ShortenRequest.swift
//  Curtz
//
//  Created by George Nyakundi on 20/11/2023.
//

import Foundation

public struct ShortenRequest {
    public let originalUrl: String
    public let customAlias: String
    public let keywords: [String]
    public let expiresOn: String
    
    public init(originalUrl: String, customAlias: String, keywords: [String], expiresOn: String) {
        self.originalUrl = originalUrl
        self.customAlias = customAlias
        self.keywords = keywords
        self.expiresOn = expiresOn
    }
}
