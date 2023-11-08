//
//  CoreServiceUnitTests.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 03/11/2023.
//

import XCTest
import Curtz


final class CoreServiceResponseMapper {
    
    private struct ShortenItem: Decodable {
        let id: String
        let custom_alias: String
        let original_url: String
        let expires_on: String
        let keywords: [String]
        let user_id: String
        let short_code: String
        let created_at: String
        let updated_at: String
        let hits: Int
        
        var response: ShortenResponse {
            return ShortenResponse(
                id: id,
                customAlias: custom_alias,
                originalUrl: original_url,
                expiresOn: expires_on,
                keywords: keywords,
                userId: user_id,
                shortCode: short_code,
                createdAt: created_at,
                updatedAt: updated_at,
                hits: hits
            )
        }
    }
    
    private struct ErrorItem: Decodable {
        let error: String
    }
    
    static func mapShorteningResponse(_ data: Data, from response: HTTPURLResponse) -> CoreService.ShorteningResult {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if response.isBadRequest() {
            let res = try? decoder.decode(ErrorItem.self, from: data)
            return .failure(CoreService.Error.clientError(res?.error ?? ""))
        }
        
        guard response.isOK(), let res = try? decoder.decode(ShortenItem.self, from: data) else {
            return .failure(CoreService.Error.invalidResponse)
        }
        
        return .success(res.response)
        
    }
}

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
    let expiresOn: String
    let keywords: [String]
    let userId: String
    let shortCode: String
    let createdAt: String
    let updatedAt: String
    let hits: Int
    
    init(id: String, customAlias: String, originalUrl: String, expiresOn: String, keywords: [String], userId: String, shortCode: String, createdAt: String, updatedAt: String, hits: Int) {
        self.id = id
        self.customAlias = customAlias
        self.originalUrl = originalUrl
        self.expiresOn = expiresOn
        self.keywords = keywords
        self.userId = userId
        self.shortCode = shortCode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.hits = hits
    }
}

extension ShortenResponse: Equatable {}

enum ShortenResult {
    case success(ShortenResponse)
    case failure(Error)
}

extension CoreService.Error: Equatable { }

class CoreService {
    private let client: HTTPClient
    private let serviceURL: URL
    
    typealias ShorteningResult = ShortenResult
    
    enum Error: Swift.Error {
        case malformedRequest
        case invalidResponse
        case clientError(String)
    }
    
    init(serviceURL: URL, client: HTTPClient) {
        self.serviceURL = serviceURL
        self.client = client
    }
    
    func shorten(_ request: ShortenRequest, completion: @escaping(ShorteningResult) -> Void) {
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
        ) { result in
            switch result {
            case let .success((data, response)):
                completion(CoreServiceResponseMapper.mapShorteningResponse(data, from: response))
            default:
                completion(.failure(Error.malformedRequest))
            }
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
        sut.shorten(testShortenRequest()){ _ in }
        XCTAssertFalse(client.requestsMade.isEmpty, "RequestShould be forwarded to the client")
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
    
    func test_ShortenURL_deliversErrorsOn2XXStatusCodes() {
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
        
        let shortenRequest = ShortenRequest(originalUrl: "https://mi.com", customAlias: "mi.com", keywords: ["sick","sickest"], expiresOn: "2024-09-28T20:00:01+00:00")
        
        let shortenResponse = makeShortenResponse(id: "cc38i5mg26u17lm37upg", customAlias: shortenRequest.customAlias, originalUrl: shortenRequest.originalUrl, expiresOn: shortenRequest.expiresOn, keywords: shortenRequest.keywords, userId: "cc38i5mg26u17lm37upg", shortCode: "", createdAt: "2023-08-28T15:07:02+00:00", updatedAt: "2023-08-28T15:07:02+00:00", hits: 0)
        
        expect(sut, with: shortenRequest, toCompleteWith: .success(shortenResponse.model)) {
            let json = makeJSON(shortenResponse.json)
            client.complete(withStatusCode: 200, data: json)
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
    
    private func failure(_ error: CoreService.Error) -> CoreService.ShorteningResult {
        .failure(error)
    }
    
    private func makeShortenResponse(
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
    ) -> (model: ShortenResponse, json: [String: Any]) {
        let item = ShortenResponse(
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
        id: String,
        customAlias: String,
        originalUrl: String,
        expiresOn: String,
        keyWords: [String],
        userId: String,
        shortCode: String,
        createdAt: String,
        updatedAt: String,
        hits: Int
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
