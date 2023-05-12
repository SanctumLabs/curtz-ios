//
//  CurtzTokenService.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 12/05/2023.
//

import Foundation
import Curtz

/**
 TODO: Think and implement
 - Save access_token and refresh_token
 - Use the refresh_token to request for new access_token
 */

final class CurtzTokenService: TokenService {
    private let storeManager: StoreManager
    
    init(storeManager: StoreManager) {
        self.storeManager = storeManager
    }
    
    func getToken(completion: @escaping GetTokenCompletion) {
        storeManager.retrieveValue(forKey: .accessTokenKey) {[weak self] result in
            guard let _ = self else { return }
            switch result {
            case let .success(token):
                completion(.success(token))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

extension String {
    static let accessTokenKey = "access_token"
}
