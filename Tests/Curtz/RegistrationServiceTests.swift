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
    
    init(urlRequest: URLRequest, client: HTTPClient) {
        self.urlRequest = urlRequest
        self.client = client
    }
}

class RegistrationServiceTests: XCTestCase {
    func test_init_doesNotRequestDataFromURLRequest() {
        let(_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLrequests.isEmpty)
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
        
        var requestedURLrequests: [URLRequest] {
            return messages.map {$0.urlRequest}
        }
        
        
        func perform(request: URLRequest, completion: @escaping (HTTPClientResult) -> Void) {
            
        }
    }
}
