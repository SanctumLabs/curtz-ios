//
//  TokenService.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 04/09/2022.
//

import Foundation

public protocol TokenService {
    typealias Result = Swift.Result<String, Error>
    typealias GetTokenCompletion = (Result) -> Void
    func getToken(completion: @escaping GetTokenCompletion )
}
