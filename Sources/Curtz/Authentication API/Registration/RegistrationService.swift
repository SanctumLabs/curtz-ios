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
    
    private func prepareRequest(for user: RegistrationRequest) -> URLRequest {
        var request = URLRequest(url: self.registrationURL)
        request.httpMethod = .POST
        request.setValue(.APPLICATION_JSON, forHTTPHeaderField: .CONTENT_TYPE)
        let requestBody: [String: String] = [
            "email": user.email,
            "password": user.password
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        return request
    }
    
    public func register(user :RegistrationRequest, completion: @escaping(Result) -> Void) {
        
        let request = prepareRequest(for: user)
        
        client.perform(request: request) {[weak self] result in
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
