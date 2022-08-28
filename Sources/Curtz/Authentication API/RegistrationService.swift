//
//  RegistrationService.swift
//  curtz-ios
//
//  Created by George Nyakundi on 28/08/2022.
//

import Foundation

public class RegistrationService {
    let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = RegistrationResult
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    private var OK_200: Int {
        return 200
    }
    
    static func prepareRequest(for user: RegistrationRequest) -> URLRequest {
        let url = URL(string: "http://any-request.com")!
        var request = URLRequest(url: url)
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
    
    public func register(user :RegistrationRequest, completion: @escaping(Result) -> Void) {
        
        let request = RegistrationService.prepareRequest(for: user)
        
        client.perform(request: request) {[weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(RegistrationMapper.map(data, from: response))
            default:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
