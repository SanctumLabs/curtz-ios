//
//  URLRequest+Sign.swift
//  curtz-ios
//
//  Created by George Nyakundi on 02/09/2022.
//

import Foundation

public extension URLRequest {
    func signed(with token: String) -> URLRequest {
        var request = self
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

extension URLRequest {
    public static func prepared(for requestType: RequestType, with url: URL) -> URLRequest {
        var request = URLRequest(url: url)
       
        switch requestType {
        case let .login(username, password):
            let requestBody: [String: String] = [
                "email": username,
                "password": password
            ]
            let jsonData = try? JSONSerialization.data(withJSONObject: requestBody)
            request.httpMethod = .POST
            request.httpBody = jsonData
            request.setValue(.APPLICATION_JSON, forHTTPHeaderField: .CONTENT_TYPE)
        case let .registration(username, password):
            let requestBody: [String: String] = [
                "email": username,
                "password": password
            ]
            let jsonData = try? JSONSerialization.data(withJSONObject: requestBody)
            request.httpMethod = .POST
            request.httpBody = jsonData
            request.setValue(.APPLICATION_JSON, forHTTPHeaderField: .CONTENT_TYPE)
            
        case let .shortening(originalUrl, customAlias, keywords, expiresOn):
            let requestBody: [String: Any] = [
                "original_url": originalUrl,
                "custom_alias": customAlias,
                "keywords": keywords,
                "expires_on": expiresOn
            ]
            let jsonData = try? JSONSerialization.data(withJSONObject: requestBody)
            request.httpMethod = .POST
            request.httpBody = jsonData
            request.setValue(.APPLICATION_JSON, forHTTPHeaderField: .CONTENT_TYPE)
        case let .refreshToken(grantType, refreshToken):
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            let grantType = URLQueryItem(name: "grant_type", value: grantType)
            let refreshToken = URLQueryItem(name: "refresh_token", value: refreshToken)
            components?.queryItems = [grantType, refreshToken]
            if let componentURL = components?.url {
                var req = URLRequest(url: componentURL)
                req.httpMethod = .POST
                return req
            }
        default:
            request.httpMethod = .GET
        }
        
        return request
    }
}

public enum RequestType {
    case login(
        username: String,
        password: String)
    case registration(
        username: String,
        password: String)
    case shortening(
        originalUrl: String,
        customAlias: String,
        keywords: [String],
        expiresOn: String)
    case refreshToken(
        grantType: String,
        refreshToken: String
    )
    case fetching
}

extension String {
    /// HTTP POST method
    static var POST = "POST"
    /// HTTP GET method
    static var GET = "GET"
    /// Content-Type
    static var CONTENT_TYPE = "Content-Type"
    /// application/json
    static var APPLICATION_JSON = "application/json"
    
}
