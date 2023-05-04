//
//  CurtzTokenStoreUnitTests.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 17/04/2023.
//

import XCTest

/*
 1. Store access_token and refresh_token
 2. Delete access_token and refresh_token
 3. Retrieve access_token and refresh_token
 */

struct SaveTokenRequest {
    let access_token: String
    let refresh_token: String
}

struct RetrieveTokenResponse {
    let access_token: String
}

enum StoreError: Error {
    case notFound
    case failedToSave
}

protocol Store {
    
    typealias RetrievalResult = Result<String, StoreError>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    typealias SaveResult = Result<Void, StoreError>
    typealias SaveCompletion = (SaveResult) -> Void
    
    func save(_ tokenRequest: SaveTokenRequest, completion: @escaping SaveCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}

final class CurtzTokenStore: Store {
    func save(_ tokenRequest: SaveTokenRequest, completion: @escaping SaveCompletion) {}
    
    func retrieve(completion: @escaping RetrievalCompletion) {}
}

/*
 Upon successful login,
 Save token to the store
  - delete existing token
  - save next token pair (access_token, refresh_token)
 */
