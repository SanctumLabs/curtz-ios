//
//  URLSessionHTTPClientTests.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 28/08/2022.
//

import XCTest
import Curtz

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func perform(request: URLRequest, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp(){
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown(){
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_performPOSTURLRequest() {
        let url =  URL(string: "http://test-any.com")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let exp = expectation(description: "wait for expectation")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "POST")
            exp.fulfill()
        }
        
        let sut = makeSUT()
        sut.perform(request: urlRequest) { _ in }
        wait(for: [exp], timeout: 1.0)
       
    }
    
    func test_request_failsOnRequestError() {
        let url =  URL(string: "http://test-any.com")!
        let urlRequest = URLRequest(url: url)
        let error = NSError(domain: "any error", code: 1)
        
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        let sut = makeSUT()
        
        let exp = expectation(description: "wait for completion")
        sut.perform(request: urlRequest) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.localizedDescription, error.localizedDescription)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> URLSessionHTTPClient {
        return URLSessionHTTPClient()
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocolStub.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        override func startLoading() {
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
