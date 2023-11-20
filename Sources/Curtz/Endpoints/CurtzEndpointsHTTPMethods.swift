//
//  CurtzEndpointsHTTPMethods.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 26/09/2022.
//

import Foundation

extension CurtzEndpoint {
    /// HTTPMethod for an endpoint
    /// - Returns: String describing the HTTPMethod
    public func httpMethod() -> String {
        switch self {
        case .register, .login, .verifyToken, .shorten:
            return "POST"
        case .deleteUrl:
            return "DELETE"
        case .updateUrl:
            return "PATCH"
        default:
            return "GET"
        }
    }
}
