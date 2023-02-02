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
        let request = prepareRequest(for: user)
        
        client.perform(request: request) {[weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(LoginMapper.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
        
        
        func prepareRequest(for user: LoginRequest) -> URLRequest {
            var request = URLRequest(url: self.loginURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let requestBody: [String: String] = [
                "email": user.email,
                "password": user.password
            ]
            let jsonData = try? JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
            
            return request
        }
    }
}
