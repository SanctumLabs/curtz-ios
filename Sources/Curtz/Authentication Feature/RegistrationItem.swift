//
//  LoginItem.swift
//  Curtz_macOS
//
//  Created by George Nyakundi on 23/08/2022.
//

import Foundation

public struct RegistrationRequest {
    public let email: String
    public let password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

public struct RegistrationResponse: Equatable {
  
    public let id: String
    public let email: String
    public let createdAt: String
    public let updatedAt: String
    
    public init(id: String, email: String, createdAt: String, updatedAt: String) {
        self.id = id
        self.email = email
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public enum RegistrationResult {
    case success (RegistrationResponse)
    case failure (Error)
}
