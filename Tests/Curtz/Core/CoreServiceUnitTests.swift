//
//  CoreServiceUnitTests.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 03/11/2023.
//

import XCTest
import Curtz




final class CoreServiceUnitTests: XCTestCase {
    
    let jsonDecoder = JSONDecoder()
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestsMade.isEmpty)
    }
    
    // MARK: - Shorten Tests
    func test_ShortenURL_performsRequest() {
        let (sut, client) = makeSUT()
        sut.shorten(testShortenRequest()){ _ in }
        XCTAssertFalse(client.requestsMade.isEmpty, "Request Should be forwarded to the client")
    }
    
    func test_ShortenURL_performsRequest_withCorrectBody() {
        let (sut, client) = makeSUT()
        let testRequest = testShortenRequest()
        sut.shorten(testRequest){ _ in }
        
        client.requestsMade.forEach { request in
            let receivedRequest = try! jsonDecoder.decode(TestShortenRequest.self, from: request.httpBody!)
            XCTAssertEqual(request.httpMethod!, "POST")
            XCTAssertEqual(receivedRequest.originalUrl, testRequest.originalUrl)
            XCTAssertEqual(receivedRequest.customAlias, testRequest.customAlias)
            XCTAssertEqual(receivedRequest.keywords, testRequest.keywords)
            XCTAssertEqual(receivedRequest.expiresOn, testRequest.expiresOn)
        }
    }
    
    func test_ShortenURL_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, with: testShortenRequest(), toCompleteWith: failure(.malformedRequest)) {
            let clientError = anyNSError()
            client.complete(with: clientError)
        }
    }
    
    func test_ShortenURL_deliversErrorsOn4XXStatusCodes() {
        let (sut, client) = makeSUT()
        let message = "Something went wrong"
        let statusCodes = [400, 401, 499]
        
        statusCodes.enumerated().forEach { index, code in
            expect(sut, with: testShortenRequest(), toCompleteWith: failure(.clientError(message))) {
                let data = makeErrorJSON(message, forKey: "error")
                client.complete(withStatusCode: code, data: data, at: index)
            }
        }
    }
    
    func test_ShortenURL_deliversErrorsOnNon2XXStatusCodes() {
        let (sut, client) = makeSUT()
        let message = "Something went wrong"
        let statusCodes = [199, 300, 500]
        
        statusCodes.enumerated().forEach { index, code in
            expect(sut, with: testShortenRequest(), toCompleteWith: failure(.invalidResponse)) {
                let data = makeErrorJSON(message, forKey: "error")
                client.complete(withStatusCode: code, data: data, at: index)
            }
        }
    }
    
    func test_ShortenURL_deliversShortenResponseOn2XXHTTPResponses() {
        let (sut, client) = makeSUT()
        
        let shortenRequest = ShortenRequest(
            originalUrl: "https://mi.com",
            customAlias: "mi.com",
            keywords: ["sick","sickest"],
            expiresOn: "2024-09-28T20:00:01+00:00"
        )
        
        let shortenResponse = makeShortenResponseItem(
            id: "cc38i5mg26u17lm37upg",
            customAlias: shortenRequest.customAlias,
            originalUrl: shortenRequest.originalUrl,
            expiresOn: shortenRequest.expiresOn,
            keywords: shortenRequest.keywords,
            userId: "cc38i5mg26u17lm37upg",
            shortCode: "",
            createdAt: "2023-08-28T15:07:02+00:00",
            updatedAt: "2023-08-28T15:07:02+00:00",
            hits: 0
        )
        
        expect(sut, with: shortenRequest, toCompleteWith: .success(shortenResponse.model)) {
            let json = makeJSON(shortenResponse.json)
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    func test_ShortenURL_doesNOTDeliverResultsAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var receivedResults = [CoreService.ShorteningResult]()
        
        var sut: CoreService? = CoreService(serviceURL: testServiceURL(), client: client)
        sut?.shorten(testShortenRequest(), completion: {
            receivedResults.append($0)
        })
        sut = nil
        client.complete(withStatusCode: 200, data: makeJSON(jsonFor()))
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: - FetchAll Tests
    
    func test_FetchAll_performsRequests() {
        let (sut, client) = makeSUT()
        sut.fetchAll { _ in
            
        }
        XCTAssertFalse(client.requestsMade.isEmpty, "A request should have been made to the client")
    }
    
    func test_FetchAll_performaRequest_withCorrectInformation() {
        let (sut, client) = makeSUT()
        sut.fetchAll(completion: { _ in } )
        
        client.requestsMade.forEach { request in
            XCTAssertEqual(request.httpMethod!, "GET")
        }
    }
    
    func test_FetchAll_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .failure(.invalidResponse)) {
            let clientError = anyNSError()
            client.complete(with: clientError)
        }
    }
    
    func test_FetchAll_deliversErrorOn4XXStatusCodes() {
        let (sut, client) = makeSUT()
        let message = "You'll need to login again"
        let statusCodes = [400, 401, 450, 499]
        statusCodes.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.clientError(message))) {
                let data = makeErrorJSON(message, forKey: "error")
                client.complete(withStatusCode: code, data: data, at: index)
            }
        }
    }
    
    func test_FetchAll_deliversErrorOnNon2XXStatusCodes() {
        let (sut, client) = makeSUT()
        let statusCodes = [199, 300, 500, 600]
        
        statusCodes.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidResponse)) {
                let data = makeErrorJSON()
                client.complete(withStatusCode: code, data: data, at: index)
            }
        }
    }
    
    func test_FetchAll_deliversResponseOn2xxStatusCodes() {
        let (sut, client) = makeSUT()
        let item1 = makeShortenResponseItem(
            id: "cc38i5mg1u17lm37upg",
            customAlias: "mi1.com",
            originalUrl: "http://mi1.com",
            expiresOn: "2024-01-28T20:00:01+00:00",
            keywords: [],
            userId: "cc38i5mg26u17lm37upg",
            shortCode: "",
            createdAt: "2023-01-28T15:07:02+00:00",
            updatedAt: "2023-01-28T15:07:02+00:00",
            hits: 1
        )
        
        let item2 = makeShortenResponseItem(
            id: "cc38i5mg2u17lm37upg",
            customAlias: "mi2.com",
            originalUrl: "http://mi2.com",
            expiresOn: "2024-02-28T20:00:01+00:00",
            keywords: [],
            userId: "cc38i5mg26u17lm37upg",
            shortCode: "",
            createdAt: "2023-02-28T15:07:02+00:00",
            updatedAt: "2023-02-28T15:07:02+00:00",
            hits: 2
        )
        
        expect(sut,toCompleteWith: .success([item1.model, item2.model])) {
            let data = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_FetchAll_doesNOTDeliverResultsAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var receivedResults = [CoreService.FetchResult]()
        
        var sut: CoreService? = CoreService(serviceURL: testServiceURL(), client: client)
        sut?.fetchAll(completion: {
            receivedResults.append($0)
        })
        sut = nil
        client.complete(withStatusCode: 200, data: makeJSON(jsonFor()))
        XCTAssertTrue(receivedResults.isEmpty, "No results should be delivered once the instance has been deallocated.")
    }
    
    
    // MARK: - Helpers
    private func testShortenRequest() -> ShortenRequest {
        ShortenRequest(originalUrl: "https://sampleUrl.com",customAlias: "alias", keywords: [], expiresOn: "")
    }
    
    struct TestShortenRequest: Decodable {
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
    
    private func expect(
        _ sut: CoreService, with request: ShortenRequest,
        toCompleteWith expectedResult: CoreService.ShorteningResult,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        let exp = expectation(description: "wait for shortening completion")
        
        sut.shorten(request) { receivedResult in
            switch(receivedResult, expectedResult) {
            case let (.success(receivedResponse), .success(expectedResponse)):
                XCTAssertEqual(receivedResponse, expectedResponse, file: file, line: line)
            case let (.failure(receivedError as CoreService.Error), .failure(expectedError as CoreService.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(
        _ sut: CoreService,
        toCompleteWith expectedResult: CoreService.FetchResult,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        let exp = expectation(description: "wait for fetch all completion")
        
        sut.fetchAll { receivedResult in
            switch(receivedResult, expectedResult) {
            case let (.success(receivedResponse), .success(expectedResponse)):
                XCTAssertEqual(receivedResponse, expectedResponse, file: file, line: line)
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: CoreService.Error) -> CoreService.ShorteningResult {
        .failure(error)
    }
    
    private func makeShortenResponseItem(
        id: String,
        customAlias: String,
        originalUrl: String,
        expiresOn: String,
        keywords: [String],
        userId: String,
        shortCode: String,
        createdAt: String,
        updatedAt: String,
        hits: Int
    ) -> (model: ShortenResponseItem, json: [String: Any]) {
        let item = ShortenResponseItem(
            id: id,
            customAlias: customAlias,
            originalUrl: originalUrl,
            expiresOn: expiresOn,
            keywords: keywords,
            userId: userId,
            shortCode: shortCode,
            createdAt: createdAt,
            updatedAt: updatedAt,
            hits: hits
        )
        
        let json = jsonFor(
            id: id,
            customAlias: customAlias,
            originalUrl: originalUrl,
            expiresOn: expiresOn,
            keyWords: keywords,
            userId: userId,
            shortCode: shortCode,
            createdAt: createdAt,
            updatedAt: updatedAt,
            hits: hits
        )
        
        return (item, json)
        
    }
    
    private func jsonFor(
        id: String = "",
        customAlias: String = "",
        originalUrl: String = "",
        expiresOn: String = "",
        keyWords: [String] = [""],
        userId: String = "",
        shortCode: String = "",
        createdAt: String = "",
        updatedAt: String = "",
        hits: Int = 0
    ) -> [String: Any] {
        return [
            "original_url": originalUrl,
            "custom_alias": customAlias,
            "expires_on": expiresOn,
            "keywords": keyWords,
            "id": id,
            "user_id": userId,
            "short_code": shortCode,
            "created_at": createdAt,
            "updated_at": updatedAt,
            "hits": hits
        ]
    }
}
