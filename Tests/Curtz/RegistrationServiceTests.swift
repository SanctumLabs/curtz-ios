//
//  SampleTests.swift
//  Curtz
//
//  Created by George Nyakundi on 17/08/2022.
//

import XCTest
import Curtz

class RegistrationService {
    let urlRequest: URLRequest
    let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    typealias Result = RegistrationResult
    
    init(urlRequest: URLRequest, client: HTTPClient) {
        self.urlRequest = urlRequest
        self.client = client
    }
    
    private var OK_200: Int {
        return 200
    }
    
    func register(completion: @escaping(Result) -> Void) {
        client.perform(request: urlRequest) { result in
            switch result {
            case let .success(_, response):
                guard response.statusCode == 200 else {
                    return completion(.failure(Error.invalidData))
                }
                completion(.failure(Error.connectivity))
            default:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

class RegistrationServiceTests: XCTestCase {
    func test_init_doesNotPerformAURLRequest() {
        let(_, client) = makeSUT()
        
        XCTAssertTrue(client.requestsMade.isEmpty)
    }
    
    func test_register_performsAURLRequest() {
        let url = URL(string: "http://any-request.com")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let (sut, client) = makeSUT(urlRequest: urlRequest)
        sut.register {_ in }
        
        XCTAssertEqual(client.requestsMade, [urlRequest])
    }
    
    func test_registerTwice_performsURLRequestTwice() {
        let url = URL(string: "http://any-request.com")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let (sut, client) = makeSUT(urlRequest: urlRequest)
        sut.register {_ in }
        sut.register {_ in }
        
        XCTAssertEqual(client.requestsMade, [urlRequest, urlRequest])
    }
    
    func test_register_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity)) {
            let clientError = NSError(domain: "RegistrationError", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_register_deliversErrorOnNon200StatusCode() {
        let (sut, client) = makeSUT()
        let statusCodes = [199, 201, 300, 400, 500]
        
        statusCodes.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let data = makeErrorJSON()
                client.complete(withStatusCode: code, data: data, at: index)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(urlRequest: URLRequest = URLRequest(url: URL(string: "http://any-url.com")!), file: StaticString = #filePath, line: UInt = #line) -> (sut: RegistrationService, client: HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RegistrationService(urlRequest: urlRequest, client: client)
        
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        
        return (sut, client)
    }
    
    private func failure(_ error: RegistrationService.Error) -> RegistrationService.Result {
        .failure(error)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
    }
    
    private func makeErrorJSON(_ message: String = "") -> Data {
        let json = ["message": message]
        return try! JSONSerialization.data(withJSONObject: json)
        
    }
    
    private func expect(_ sut: RegistrationService, toCompleteWith expectedResult: RegistrationService.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for registration completion")
        
        sut.register { receivedResult in
            switch(receivedResult, expectedResult) {
            case let (.success(receivedResponse), .success(expectedResponse)):
                XCTAssertEqual(receivedResponse, expectedResponse, file: file, line: line)
            case let (.failure(receivedError as RegistrationService.Error), .failure(expectedError as RegistrationService.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [
            (urlRequest: URLRequest, completion: (HTTPClientResult) -> Void)
        ]()
        
        var requestsMade: [URLRequest] {
            return messages.map {$0.urlRequest}
        }
        
        
        func perform(request: URLRequest, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((request, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: messages[index].urlRequest.url!, statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
