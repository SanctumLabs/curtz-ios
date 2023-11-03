//
//  RegistrationServiceTests.swift
//  Curtz
//
//  Created by George Nyakundi on 17/08/2022.
//

import XCTest
import Curtz

class RegistrationServiceTests: XCTestCase {
    func test_init_doesNotPerformAURLRequest() {
        let(_, client) = makeSUT()
        
        XCTAssertTrue(client.requestsMade.isEmpty)
    }
    
    func test_register_performsRequest_withSomeHTTPBody() {
        let (sut, client) = makeSUT()
        
        sut.register(user: testUser()) {_ in }
        client.requestsMade.forEach { request in
            XCTAssertNotNil(request.httpBody, "request body should not be empty")
        }
    }
    
    func test_register_performsRequest_withCorrectInformation() {
        let jsonDecoder = JSONDecoder()
        let (sut, client) = makeSUT()
        let userRequestSent = RegistrationRequest(email: "first@email.com", password: "strong-password")
        
        sut.register(user: userRequestSent) { _ in }
        
        client.requestsMade.forEach { request in
            let userRequestReceived = try! jsonDecoder.decode(TestRequest.self, from: request.httpBody!)
            
            XCTAssertEqual(request.httpMethod!, "POST")
            XCTAssertEqual(userRequestReceived.email, userRequestSent.email)
            XCTAssertEqual(userRequestReceived.password, userRequestSent.password)
        }
    }
    
    func test_register_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, registering: testUser(), toCompleteWith: failure(.connectivity)) {
            let clientError = anyNSError()
            client.complete(with: clientError)
        }
    }
    
    func test_register_deliversErrorOnNon200StatusCode() {
        let (sut, client) = makeSUT()
        let statusCodes = [199, 201, 300, 500]
        
        statusCodes.enumerated().forEach { index, code in
            expect(sut, registering: testUser(), toCompleteWith: failure(.invalidData)) {
                let data = makeErrorJSON()
                client.complete(withStatusCode: code, data: data, at: index)
            }
        }
    }
    
    func test_register_deliversErrorMessageForClientErrorStatusCode() {
        let (sut, client) = makeSUT()
        let statusCode = 400
        let serverMessage = "User already exists"
        
        expect(sut, registering: testUser(), toCompleteWith: failure(.clientError(serverMessage))) {
            let data = makeErrorJSON(serverMessage)
            client.complete(withStatusCode: statusCode, data: data)
        }
    }
    
    func test_register_deliversRegistrationResponseOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let thisUser = RegistrationRequest(email: "email@strong-server.com", password: "serious-password")
        let registrationResponse = makeRegistrationResponse(
            id: "cc38i5mg26u17lm37upg",
            email: thisUser.email,
            createdAt: (Date(timeIntervalSince1970: 1598627222),"2020-08-28T15:07:02+00:00"),
            updatedAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00")
        )
        
        expect(sut, registering: thisUser, toCompleteWith: .success(registrationResponse.model)) {
            let json = makeJSON(registrationResponse.json)
            client.complete(withStatusCode: 200, data: json)
        }
        
    }
    
    func test_register_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var capturedResult = [RegistrationService.Result]()
        
        var sut: RegistrationService? = RegistrationService(registrationURL: testRegistrationURL(), client: client)
        sut?.register(user: testUser()){capturedResult.append($0)}
        
        sut = nil
        
        client.complete(withStatusCode: 200, data: makeJSON(jsonFor()))
        XCTAssertTrue(capturedResult.isEmpty)
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RegistrationService, client: HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RegistrationService(registrationURL: testRegistrationURL(), client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    private struct TestRequest: Codable {
        let email: String
        let password: String
    }
    
    private func failure(_ error: RegistrationService.Error) -> RegistrationService.Result {
        .failure(error)
    }
    
    private func testUser() -> RegistrationRequest {
        return RegistrationRequest(email: "test@email.com", password: "test-password-long-one")
    }
    
    private func testRegistrationURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private func testRequest(for user: RegistrationRequest) -> URLRequest {
        
        var urlRequest = URLRequest(url: testRegistrationURL())
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody: [String: String] = [
            "email": user.email,
            "password": user.password
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: requestBody)
        urlRequest.httpBody = jsonData
        
        return urlRequest
    }
    
    private func makeRegistrationResponse(
        id: String,
        email: String,
        createdAt: (date: Date, iso8601String: String),
        updatedAt: (date: Date, iso8601String: String)
    )
    -> (model: RegistrationResponse, json: [String: Any])
    {
        let item = RegistrationResponse(
            id: id,
            email: email,
            createdAt: createdAt.iso8601String,
            updatedAt: updatedAt.iso8601String
        )
        
        let json = jsonFor(
            id: id,
            email: email,
            date: createdAt.iso8601String
        )
        return (item, json)
        
    }
    
    private func makeJSON(_ res: [String: Any]) -> Data {
        return try! JSONSerialization.data(withJSONObject: res)
    }
    
    private func jsonFor(id: String = "", email: String = "", date: String = "") -> [String: String] {
        return [
            "id": id,
            "email": email,
            "created_at": date,
            "updated_at": date
        ]
    }
    
    private func makeErrorJSON(_ message: String = "") -> Data {
        let json = ["message": message]
        return try! JSONSerialization.data(withJSONObject: json)
        
    }
    
    private func expect(
        _ sut: RegistrationService,
        registering user: RegistrationRequest,
        toCompleteWith expectedResult: RegistrationService.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for registration completion")
        
        sut.register(user: user) { receivedResult in
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
}
