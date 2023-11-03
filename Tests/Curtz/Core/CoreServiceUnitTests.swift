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
    let customAlias: String
    let keywords: [String]
    let expiresOn: String
    
    init(originalUrl: String, customAlias: String, keywords: [String], expiresOn: String) {
        self.originalUrl = originalUrl
        self.customAlias = customAlias
        self.keywords = keywords
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
                    customAlias: request.customAlias,
                    keywords: request.keywords,
                    expiresOn: request.expiresOn
                ),
                with: serviceURL
            )
        ) { _ in
            
        }
    }
}

final class CoreServiceUnitTests: XCTestCase {
    
    let jsonDecoder = JSONDecoder()
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestsMade.isEmpty)
    }
    
    func test_ShortenURL_performsRequest() {
        let (sut, client) = makeSUT()
        sut.shorten(testShortenRequest())
        XCTAssertFalse(client.requestsMade.isEmpty, "RequestShould be forwarded to the client")
    }
    
    func test_ShortenURL_performsRequest_withCorrectBody() {
        let (sut, client) = makeSUT()
        let testRequest = testShortenRequest()
        sut.shorten(testRequest)
        
        client.requestsMade.forEach { request in
            let receivedRequest = try! jsonDecoder.decode(TestShortenRequest.self, from: request.httpBody!)
            XCTAssertEqual(request.httpMethod!, "POST")
            XCTAssertEqual(receivedRequest.originalUrl, testRequest.originalUrl)
            XCTAssertEqual(receivedRequest.customAlias, testRequest.customAlias)
            XCTAssertEqual(receivedRequest.keywords, testRequest.keywords)
            XCTAssertEqual(receivedRequest.expiresOn, testRequest.expiresOn)
        }
    }

    // MARK: - Helpers
    private func testShortenRequest() -> ShortenRequest {
        ShortenRequest(originalUrl: "https://sampleUrl.com",customAlias: "alias", keywords: [], expiresOn: "")
    }
    
    private struct TestShortenRequest: Decodable {
        let originalUrl: String
        let customAlias: String
        let keywords: [String]
        let expiresOn: String
        
        enum CodingKeys:String, CodingKey {
            case originalUrl = "original_url"
            case customAlias = "custom_alias"
            case keywords
            case expiresOn =  "expires_on"
        }
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
