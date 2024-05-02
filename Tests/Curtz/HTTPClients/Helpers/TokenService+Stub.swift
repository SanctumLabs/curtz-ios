//
//  File.swift
//  CurtzAllTests
//
//  Created by George Nyakundi on 03/11/2023.
//

import Foundation
import Curtz

final class GetTokenServiceStub: TokenService {
    
    let result: TokenService.Result
    
    init(stubbedToken token: String) {
        self.result = .success(token)
    }
    
    init(stubbedError: Error) {
        self.result = .failure(stubbedError)
    }
    func getToken(completion: @escaping (TokenService.Result) -> Void) {
        completion(result)
    }
}

final class GetTokenServiceSpy: TokenService {
    
    var getTokenCompletions = [(TokenService.Result) -> Void]()
    
    var getTokenCount: Int {
        getTokenCompletions.count
    }
    
    func getToken(completion: @escaping (TokenService.Result) -> Void) {
        getTokenCompletions.append(completion)
    }
    
    func complete(with error: Error, at index: Int = 0) {
        getTokenCompletions[index](.failure(error))
    }
    
    func completeSuccessfully(with token: String, at index: Int = 0) {
        getTokenCompletions[index](.success(token))
    }
}
