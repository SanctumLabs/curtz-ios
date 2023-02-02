//
//  CurtzEndpoints.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 26/09/2022.
//

import Foundation

public enum CurtzEndpoint {
    case health
    case register
    case login
    case verifyToken
    case create
    case fetchAll
    case fetchById(String)
    case deleteUrl(String)
    case updateUrl(String)
    case fetchByShortCode(String)
    
    /// Returns a valid Curtz URL
    /// - Parameters:
    ///   - baseURL: BaseURL to where the service is hosted
    ///   - apiVersion: the API version in use, defaults to "v1"
    /// - Returns: a valid url to Curtz endpoints
    public func url(baseURL: URL, apiVersion: String = "v1") -> URL {
        switch self {
        case .health:
            return baseURL.appendingPathComponent("/health")
        case .register:
            return baseURL.appendingPathComponent("/api/\(apiVersion)/curtz/auth/register")
        case .login:
            return baseURL.appendingPathComponent("/api/\(apiVersion)/curtz/auth/login")
        case .verifyToken:
            return baseURL.appendingPathComponent("/api/\(apiVersion)/curtz/auth/oauth/token")
        case .create:
            return baseURL.appendingPathComponent("/api/\(apiVersion)/curtz/urls")
        case .fetchAll:
            return baseURL.appendingPathComponent("/api/\(apiVersion)/curtz/urls")
        case .fetchById(let id):
            return baseURL.appendingPathComponent("/api/\(apiVersion)/curtz/urls/\(id)")
        case .deleteUrl(let id):
            return baseURL.appendingPathComponent("/api/\(apiVersion)/curtz/urls/\(id)")
        case .updateUrl(let id):
            return baseURL.appendingPathComponent("/api/\(apiVersion)/curtz/urls/\(id)")
        case .fetchByShortCode(let shortCode):
            return baseURL.appendingPathComponent("/\(shortCode)")
        }
    }
}
