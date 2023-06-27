//
//  URLServiceUnitTests.swift
//  CurtzAllTests
//
//  Created by George Nyakundi on 27/06/2023.
//

import XCTest
import Curtz

final class URLServiceUnitTests: XCTestCase {
    func test_init_doesNOT_performAnyRequests() {
        let ( _, client) = makeSUT()
        
        XCTAssert(client.requestsMade.isEmpty)
    }
    
    func test_shortenURL_performsRequestWithCorrectInformation(){
        
        let jsonDecoder = JSONDecoder()
        
        let (sut, client) = makeSUT()
        let urlToShorten = "http://crazy-website.com"
        let keywords = ["fancy", "another one"]
        let expiresOn = "2022-10-20T09:16:07.70609+02:00"
        
        let requestSent = ShorteningRequest(originalUrl: urlToShorten, keywords: keywords, expiresOn: expiresOn)
        sut.shorten(urlRequest: requestSent)
        
        client.requestsMade.forEach { request in
            let requestReceived = try! jsonDecoder.decode(TestShorteningRequest.self, from: request.httpBody!)
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url, testShorteningURL())
            XCTAssertEqual(requestSent.keywords, requestReceived.keywords)
            XCTAssertEqual(requestSent.expiresOn, requestReceived.expiresOn)
            XCTAssertEqual(requestSent.originalUrl, requestReceived.originalUrl)
        }
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: CurtzURLService, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = CurtzURLService(httpClient: client, serviceURL: testShorteningURL())
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
        
    }
    
    private func testShorteningURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private struct TestShorteningRequest: Decodable {
        let originalUrl: String
        let keywords: [String]
        let expiresOn: String
        
        enum CodingKeys: String, CodingKey {
            case originalURL = "original_url"
            case keywords = "keywords"
            case expiresOn = "expires_on"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.originalUrl = try container.decode(String.self, forKey: .originalURL)
            self.keywords = try container.decode([String].self, forKey: .keywords)
            self.expiresOn = try container.decode(String.self, forKey: .expiresOn)
        }
    }
}

