//
//  LoginService.swift
//  Curtz
//
//  Created by George Nyakundi on 02/02/2023.
//

import Foundation

public class LoginService {
    private let client: HTTPClient
    private let loginURL: URL
    
    public typealias Result = LoginResult
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(loginURL: URL, client: HTTPClient) {
        self.client = client
        self.loginURL = loginURL
    }
    
    public func login(user: LoginRequest, completion: @escaping (Result) -> Void) {
        
        client.perform(request: .prepared(for: .login(username: user.email, password: user.password), with: self.loginURL)) {[weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(LoginMapper.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
