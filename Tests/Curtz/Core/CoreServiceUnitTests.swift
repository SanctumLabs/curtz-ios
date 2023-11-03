//
//  CoreServiceUnitTests.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 03/11/2023.
//

import XCTest
import Curtz


class CoreService {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
}

final class CoreServiceUnitTests: XCTestCase {
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestsMade.isEmpty)
    }
    
   
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: CoreService, client: HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = CoreService(client: client)
        
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        
        return (sut, client)
    }
}
