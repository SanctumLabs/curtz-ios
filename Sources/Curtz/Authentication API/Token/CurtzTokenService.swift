//
//  CurtzTokenService.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 12/05/2023.
//

import Foundation
/**
 TODO: Think and implement
 - Save access_token and refresh_token
 - Use the refresh_token to request for new access_token
 */

public final class CurtzTokenService: TokenService {
   
    private let storeManager: StoreManager
    private let client: HTTPClient
    private let refreshTokenURL: URL
    
    public init(storeManager: StoreManager, client: HTTPClient, refreshTokenURL: URL) {
        self.storeManager = storeManager
        self.client = client
        self.refreshTokenURL = refreshTokenURL
    }
    
    public func getToken(completion: @escaping GetTokenCompletion) {
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
    
    public func refreshToken(completion: @escaping RefreshTokenCompletion) {
        storeManager.retrieveValue(forKey: .refreshTokenKey) {[weak self] result in
            guard let self else { return }
            switch result {
            case let .success(token):
                self.client.perform(
                    request: .prepared(
                        for: .refreshToken(
                            grantType: .refreshTokenKey,
                            refreshToken: token
                        ), with: refreshTokenURL
                    )
                ) {[weak self ] receivedResult in
                    guard let self else { return }
                    switch receivedResult {
                    case let .success((data, response)):
                        let result = TokenResponseMapper.map(data, from: response)
                        switch result {
                        case let .success(tokenResult):
                            self.storeManager.save(tokenResult.accessToken, forKey: .accessTokenKey) { _ in }
                            self.storeManager.save(tokenResult.refreshToken, forKey: .refreshTokenKey) { _ in }
                            completion(.success(tokenResult.accessToken))
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

extension String {
    static let accessTokenKey = "access_token"
    static let refreshTokenKey = "refresh_token"
}
