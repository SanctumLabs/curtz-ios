//
//  CoreServiceUnitTests.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 03/11/2023.
//

import XCTest
import Curtz


struct ShortenRequest {
    let originalUrl: String
    let keyWords: [String]
    let expiresOn: String
    
    init(originalUrl: String, keyWords: [String], expiresOn: String) {
        self.originalUrl = originalUrl
        self.keyWords = keyWords
        self.expiresOn = expiresOn
    }
}

struct ShortenResponse {
    let id: String
    let customAlias: String
    let originalUrl: String
    let keywords: [String]
    let userId: String
    let shortCode: String
    let createdAt: String
    let updatedAt: String
    let hits: Int
}

enum ShortenResult {
    case success(ShortenResponse)
    case failure(Error)
}

class CoreService {
    private let client: HTTPClient
    private let serviceURL: URL
    
    init(serviceURL: URL, client: HTTPClient) {
        self.serviceURL = serviceURL
        self.client = client
    }
    
    func shorten(_ request: ShortenRequest) {
        client.perform(
            request: .prepared(
                for: .shortening(
                    originalUrl: request.originalUrl,
                    keywords: request.keyWords,
                    expiresOn: request.expiresOn
                ),
                with: serviceURL
            )
        ) { _ in
            
        }
    }
}

final class CoreServiceUnitTests: XCTestCase {
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestsMade.isEmpty)
    }
    
    func test_ShortenURL_performsRequest_withSomeHTTPBody() {
        let (sut, client) = makeSUT()
        sut.shorten(testShortenRequest())
        XCTAssertFalse(client.requestsMade.isEmpty, "RequestShould be forwarded to the client")
    }

    // MARK: - Helpers
    private func testShortenRequest() -> ShortenRequest {
        ShortenRequest(originalUrl: "", keyWords: [], expiresOn: "")
    }
    
    private func testServiceURL() -> URL {
        URL(string: "https://secure-login.com")!
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: CoreService, client: HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = CoreService(serviceURL: testServiceURL(), client: client)
        
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        
        return (sut, client)
    }
}
