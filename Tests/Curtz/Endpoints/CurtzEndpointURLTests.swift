//
//  CurtzEndpointTests.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 26/09/2022.
//

import XCTest
import Curtz

class CurtzEndpointTests: XCTestCase {
    func test_health_v1_endpointURL() {
        let healthURL = URL(string: "\(anyBaseURL())/health")!
        
        expect(healthURL, whenEndpointIs: .health, withBaseURL: anyBaseURL())
    }
    
    func test_register_v1_endpointURL() {
        let registerURL = URL(string: "\(anyBaseURLString())/api/v1/curtz/auth/register")!
        
        expect(registerURL, whenEndpointIs: .register, withBaseURL: anyBaseURL())
    }
    
    func test_login_v1_endpointURL() {
        let loginURL = URL(string: "\(anyBaseURLString())/api/v1/curtz/auth/login")!
        
        expect(loginURL, whenEndpointIs: .login, withBaseURL: anyBaseURL())
    }
    
    func test_verifyToken_v1_endpointURL() {
        let verifyTokenURL = URL(string: "\(anyBaseURLString())/api/v1/curtz/auth/oauth/token")!
        expect(verifyTokenURL, whenEndpointIs: .verifyToken, withBaseURL: anyBaseURL())
    }
    
    func test_create_v1_endpointURL() {
        let createURL = URL(string: "\(anyBaseURLString())/api/v1/curtz/urls")!
        
        expect(createURL, whenEndpointIs: .shorten, withBaseURL: anyBaseURL())
    }
    
    func test_fetchAll_v1_endpointURL() {
        let fetchAllURL = URL(string: "\(anyBaseURLString())/api/v1/curtz/urls")!
        
        expect(fetchAllURL, whenEndpointIs: .fetchAll, withBaseURL: anyBaseURL())
    }
    
    func test_fetchById_v1_endpointURL() {
        let fetchbyIdURL = URL(string: "\(anyBaseURLString())/api/v1/curtz/urls/234343")!
        
        expect(fetchbyIdURL, whenEndpointIs: .fetchById("234343"), withBaseURL: anyBaseURL())
    }
    
    func test_deleteURL_v1_endpointURL() {
        let deletebyIdURL = URL(string: "\(anyBaseURLString())/api/v1/curtz/urls/434343")!
        
        expect(deletebyIdURL, whenEndpointIs: .deleteUrl("434343"), withBaseURL: anyBaseURL())
    }
    
    func test_updateURL_v1_endpointURL() {
        let updateURL = URL(string: "\(anyBaseURLString())/api/v1/curtz/urls/434343")!
        
        expect(updateURL, whenEndpointIs: .updateUrl("434343"), withBaseURL: anyBaseURL())
    }
    
    func test_updateURL_v2_endpointURL() {
        let updateURL = URL(string: "\(anyBaseURLString())/api/v2/curtz/urls/434343")!
        
        expect(updateURL, whenEndpointIs: .updateUrl("434343"), andApiVersion: "v2", withBaseURL: anyBaseURL())
    }
    
    func test_fetchByShortCode_v1_endpointURL() {
        let fetchByShortCodeURL = URL(string: "\(anyBaseURLString())/434343")!
        
        expect(fetchByShortCodeURL, whenEndpointIs: .fetchByShortCode("434343"), withBaseURL: anyBaseURL())
    }

    // MARK: Helpers
    /// Endpoint test helper
    /// - Parameters:
    ///   - expectedURL: resultant url
    ///   - endpoint: one of the cases of Curtz endpoint
    ///   - baseURL: baseURL which forms the endpoint
    ///   - file: The file where the failure occurs. The default is the filename of the test case where you call this function.
    ///   - line: The line number where the failure occurs. The default is the line number where you call this function.
    private func expect(
        _ expectedURL: URL,
        whenEndpointIs endpoint: CurtzEndpoint,
        andApiVersion apiVersion: String = "v1",
        withBaseURL baseURL: URL,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let receivedURL = endpoint.self.url(baseURL: baseURL, apiVersion: apiVersion)
        XCTAssertEqual(expectedURL, receivedURL, file: file, line: line)
    }
    
    private func anyBaseURL() -> URL {
        return URL(string: anyBaseURLString())!
    }
    
    private func anyBaseURLString() -> String {
        "http://base-url.com"
    }
}
