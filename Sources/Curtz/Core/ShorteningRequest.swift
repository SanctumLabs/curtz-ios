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
