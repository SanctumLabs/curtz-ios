//
//  AuthService.swift
//  Curtz
//
//  Created by George Nyakundi on 02/02/2023.
//

import Foundation

public class AuthService {
    private let client: HTTPClient
    private let storeManager: StoreManager
    private let loginURL: URL
    
    public typealias Result = LoginResult
    public enum Error: Swift.Error {
        case connectivity
        case wrongCredentials
        case invalidData
    }
    
    public init(loginURL: URL, client: HTTPClient, storeManager: StoreManager) {
        self.client = client
        self.loginURL = loginURL
        self.storeManager = storeManager
    }
    
    public func login(user: LoginRequest, completion: @escaping (Result) -> Void) {
        
        client.perform(request: .prepared(for: .login(username: user.email, password: user.password), with: self.loginURL)) {[weak self] result in
            guard let self else { return }
            switch result {
            case let .success((data, response)):
                let result = LoginMapper.map(data, from: response)
                
                if case let .success(res) = result {
                    self.storeManager.save(res.accessToken, forKey: .accessTokenKey) { _ in }
                    self.storeManager.save(res.refreshToken, forKey: .refreshTokenKey) { _ in }
                }
                
                completion(result)
                
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    public func logout() {
        storeManager.removeValue(forKey: .accessTokenKey) { _ in }
        storeManager.removeValue(forKey: .refreshTokenKey) { _ in }
    }
}
