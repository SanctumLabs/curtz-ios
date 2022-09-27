//
//  CurtzEndpointHTTPMethods.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 27/09/2022.
//

import XCTest
import Curtz

class CurtzEndpointHTTPMethods: XCTestCase {
    func test_registerEndpoint_shouldReturn_POST() {
        XCTAssertEqual(CurtzEndpoint.register.httpMethod(), "POST")
    }
    
    func test_loginEndpoint_shouldReturn_POST() {
        XCTAssertEqual(CurtzEndpoint.login.httpMethod(), "POST")
    }
    
    func test_verifyTokenEndpoint_shouldReturn_POST() {
        XCTAssertEqual(CurtzEndpoint.verifyToken.httpMethod(), "POST")
    }
    
    func test_createEndpoint_shouldReturn_POST() {
        XCTAssertEqual(CurtzEndpoint.create.httpMethod(), "POST")
    }
    
    func test_deleteEndpoint_shouldReturn_DELETE() {
        XCTAssertEqual(CurtzEndpoint.deleteUrl("1").httpMethod(), "DELETE")
    }
    
    func test_updateUrlEndpoint_shouldReturn_PATCH() {
        XCTAssertEqual(CurtzEndpoint.updateUrl("2").httpMethod(), "PATCH")
    }
    
    func test_fetchByShortCodeEndpoint_shouldReturn_GET() {
        XCTAssertEqual(CurtzEndpoint.fetchByShortCode("3").httpMethod(), "GET")
    }
    
    func test_healthEndpoint_shouldReturn_GET() {
        XCTAssertEqual(CurtzEndpoint.health.httpMethod(), "GET")
    }
    
    func test_fetchByIdEndpoint_shouldReturn_GET() {
        XCTAssertEqual(CurtzEndpoint.fetchById("3").httpMethod(), "GET")
    }
    
    func test_fetchAllEndpoint_shouldReturn_GET() {
        XCTAssertEqual(CurtzEndpoint.fetchAll.httpMethod(), "GET")
    }
}
