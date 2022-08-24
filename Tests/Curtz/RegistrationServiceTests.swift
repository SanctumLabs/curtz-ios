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
    
    typealias Result = RegistrationResponse
    
    init(urlRequest: URLRequest, client: HTTPClient) {
        self.urlRequest = urlRequest
        self.client = client
    }
    
    func register(completion: @escaping(Result) -> Void) {
        client.perform(request: urlRequest) { _ in

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
    
    // MARK: - Helpers
    
    private func makeSUT(urlRequest: URLRequest = URLRequest(url: URL(string: "http://any-url.com")!), file: StaticString = #filePath, line: UInt = #line) -> (sut: RegistrationService, client: HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RegistrationService(urlRequest: urlRequest, client: client)
        
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        
        return (sut, client)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
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
    }
}
