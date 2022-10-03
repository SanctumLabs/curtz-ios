//
//  HTTPClient.swift
//  Curtz
//
//  Created by George Nyakundi on 17/08/2022.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func perform(request : URLRequest, completion: @escaping(Result) -> Void)
}
