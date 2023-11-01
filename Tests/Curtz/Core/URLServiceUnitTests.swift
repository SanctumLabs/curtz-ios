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
        sut.shorten(urlRequest: testShorteningRequest()) { _ in }
        
        client.requestsMade.forEach { request in
            let requestReceived = try! jsonDecoder.decode(TestShorteningRequest.self, from: request.httpBody!)
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url, testShorteningURL())
            XCTAssertEqual(testShorteningRequest().keywords, requestReceived.keywords)
            XCTAssertEqual(testShorteningRequest().expiresOn, requestReceived.expiresOn)
            XCTAssertEqual(testShorteningRequest().originalUrl, requestReceived.originalUrl)
        }
    }
    
    func test_shortenURL_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, shortening: testShorteningRequest(), toCompleteWith: failure(.invalidData)) {
            let clientError = anyNSError()
            client.complete(with: clientError)
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
    
    private func testShorteningRequest() -> ShorteningRequest {
        let urlToShorten = "http://crazy-website.com"
        let keywords = ["fancy", "another one"]
        let expiresOn = "2022-10-20T09:16:07.70609+02:00"
        
        return ShorteningRequest(originalUrl: urlToShorten, keywords: keywords, expiresOn: expiresOn)
    }
    
    private func expect(_ sut: CurtzURLService, shortening shorteningRequest: ShorteningRequest, toCompleteWith expectedResult: CurtzURLService.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let expectation = expectation(description: "wait for expectation")
        
        sut.shorten(urlRequest: shorteningRequest) { receivedResult in
            switch(receivedResult, expectedResult) {
            case let (.success(receievedResponse), .success(expectedResponse)):
                XCTAssertEqual(receievedResponse, expectedResponse, file: file, line: line)
            case let (.failure(receivedError as CurtzURLService.Error), .failure(expectedError as CurtzURLService.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult)", file: file, line: line)
            }
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func failure(_ error: CurtzURLService.Error) -> CurtzURLService.Result {
        .failure(error)
    }
}

