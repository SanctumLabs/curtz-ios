//
//  HTTPClient.swift
//  Curtz
//
//  Created by George Nyakundi on 17/08/2022.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func perform(request : URLRequest, completion: @escaping(HTTPClientResult) -> Void)
}
