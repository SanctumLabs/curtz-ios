//
//  RegistrationService.swift
//  curtz-ios
//
//  Created by George Nyakundi on 28/08/2022.
//

import Foundation

public class RegistrationService {
    let client: HTTPClient
    let registrationURL: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = RegistrationResult
    
    public init(registrationURL: URL, client: HTTPClient) {
        self.client = client
        self.registrationURL = registrationURL
    }
    
    public func register(user :RegistrationRequest, completion: @escaping(Result) -> Void) {
        
        client.perform(request: .prepared(for: .registration(username: user.email, password: user.password), with: self.registrationURL)) {[weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(RegistrationMapper.map(data, from: response))
            default:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
