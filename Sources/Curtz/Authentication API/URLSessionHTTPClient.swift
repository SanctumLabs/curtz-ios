//
//  URLSessionHTTPClient.swift
//  curtz-ios
//
//  Created by George Nyakundi on 02/09/2022.
//

import Foundation


public class URLSessionHTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedValuesRepresentation: Error { }
    
    public func perform(request: URLRequest, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            }
            else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}

