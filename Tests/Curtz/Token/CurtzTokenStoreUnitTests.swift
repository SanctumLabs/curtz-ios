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

enum StoreError: Error {
    case notFound
    case failedToSave
}

protocol Store {
    func retrieve()
}

final class CurtzStore: Store {
    func retrieve() {}
}
