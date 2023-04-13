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
