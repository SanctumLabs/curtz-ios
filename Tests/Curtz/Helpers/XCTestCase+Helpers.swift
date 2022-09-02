//
//  XCTestCase+Helpers.swift
//  curtz-ios
//
//  Created by George Nyakundi on 02/09/2022.
//

import Foundation

public func anyUrl() -> URL {
    URL(string: "http://test-any.com")!
}

public func anyURLRequest() -> URLRequest {
    URLRequest(url: anyUrl())
}

public func anyData() -> Data {
    Data("any data".utf8)
}

public func anyToken() -> String {
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NjIxMzI3NzEsImlhdCI6MTY2MjEzMTg3MSwiaXNzIjoiY3VydHoiLCJzdWIiOiJjYnVqZDhlZzI2dWRyYWUycmVuZyIsImlkIjoiY2J1amQ4ZWcyNnVkcmFlMnJlbmcifQ.RsEdoLEROEqH7t4ddeZfCwN7frFhydqnAj2p8yaHtCQ"
}
