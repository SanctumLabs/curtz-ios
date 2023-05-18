//
//  LoginItem.swift
//  Curtz_macOS
//
//  Created by George Nyakundi on 23/08/2022.
//

import Foundation

public struct LoginRequest {
    public let email: String
    public let password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

public struct LoginResponse: Equatable {
    public let id: String
    public let email: String
    public let createdAt: String
    public let updatedAt: String
    public let accessToken: String
    public let refreshToken: String
    
    public init(id: String, email: String, createdAt: String, updatedAt: String, accessToken: String, refreshToken: String) {
        self.id = id
        self.email = email
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

public enum LoginResult {
    case success (LoginResponse)
    case failure (Error)
}

