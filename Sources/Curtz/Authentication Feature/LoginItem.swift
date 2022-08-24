//
//  LoginItem.swift
//  Curtz_macOS
//
//  Created by George Nyakundi on 23/08/2022.
//

import Foundation

public struct LoginRequestItem {
    public let email: String
    public let password: String
}

public struct LoginResponseItem {
    public let id: String
    public let email: String
    public let createdAt: String
    public let updatedAt: String
}
