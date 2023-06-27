//
//  CurtzURLService.swift
//  curtz-ios
//
//  Created by George Nyakundi on 27/06/2023.
//

import Foundation


public final class CurtzURLService {
    private let httpClient: HTTPClient
    private let serviceURL: URL
    
    public init(httpClient: HTTPClient, serviceURL: URL) {
        self.httpClient = httpClient
        self.serviceURL = serviceURL
    }
    
    public func shorten(urlRequest: ShorteningRequest) {
        httpClient.perform(request: .prepared(for: .shortening(originalUrl: urlRequest.originalUrl, keywords: urlRequest.keywords, expiresOn: urlRequest.expiresOn), with: serviceURL)) { _ in
            
        }
    }
}

