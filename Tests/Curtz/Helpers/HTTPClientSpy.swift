//
//  HTTPClientSpy.swift
//  curtz-ios
//
//  Created by George Nyakundi on 02/09/2022.
//

import Foundation


public class HTTPClientSpy: HTTPClient {
    public init(){}
    private var messages = [
        (urlRequest: URLRequest, completion: (HTTPClientResult) -> Void)
    ]()
    
    public var requestsMade: [URLRequest] {
        return messages.map {$0.urlRequest}
    }
    
    public func perform(request: URLRequest, completion: @escaping (HTTPClientResult) -> Void) {
        messages.append((request, completion))
    }
    
    public func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    public func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(url: messages[index].urlRequest.url!, statusCode: code, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success(data, response))
    }
}
