//
//  SampleTests.swift
//  Curtz
//
//  Created by George Nyakundi on 17/08/2022.
//

import XCTest
import Curtz

class RegistrationService {
    let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    typealias Result = RegistrationResult
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    private var OK_200: Int {
        return 200
    }
    
    static func prepareRequest(for user: RegistrationRequest) -> URLRequest {
        let url = URL(string: "http://any-request.com")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody: [String: String] = [
            "email": user.email,
            "password": user.password
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        return request
    }
    
    func register(user :RegistrationRequest, completion: @escaping(Result) -> Void) {
        
        let request = RegistrationService.prepareRequest(for: user)
        
        client.perform(request: request) {[weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(RegistrationMapper.map(data, from: response))
            default:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

final class RegistrationMapper {
    
    private struct Item: Decodable {
        let id: String
        let email: String
        let created_at: Date
        let updated_at: Date
        
        var response: RegistrationResponse {
            return RegistrationResponse(id: id, email: email, createdAt: created_at, updatedAt: updated_at)
        }
    }
    
    private static var OK_200: Int {
        return 200
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) -> RegistrationService.Result{
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard isOK(response), let res = try? decoder.decode(Item.self, from: data) else {
            return .failure(RegistrationService.Error.invalidData)
        }
        return .success(res.response)
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}

final class RegistrationEncoder {
    
    struct Item: Encodable {
        let email: String
        let password: String
    }
    
    static func encode(_ registrationRequest: Item) -> Data {
        return try! JSONEncoder().encode(registrationRequest)
    }
}

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
            let clientError = NSError(domain: "RegistrationError", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_register_deliversErrorOnNon200StatusCode() {
        let (sut, client) = makeSUT()
        let statusCodes = [199, 201, 300, 400, 500]
        
        statusCodes.enumerated().forEach { index, code in
            expect(sut, registering: testUser(), toCompleteWith: failure(.invalidData)) {
                let data = makeErrorJSON()
                client.complete(withStatusCode: code, data: data, at: index)
            }
        }
    }
    
    func test_register_deliversRegistrationResponseOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let thisUser = RegistrationRequest(email: "email@strong-server.com", password: "serious-password")
        let registrationResponse = makeRegistrationResponse(id: "cc38i5mg26u17lm37upg", email: thisUser.email, createdAt: (Date(timeIntervalSince1970: 1598627222),"2020-08-28T15:07:02+00:00"), updatedAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"))
        
                expect(sut, registering: thisUser, toCompleteWith: .success(registrationResponse.model)) {
                    let json = makeJSON(registrationResponse.json)
                    client.complete(withStatusCode: 200, data: json)
                }
        
    }
    
    func test_register_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var capturedResult = [RegistrationService.Result]()
        
        var sut: RegistrationService? = RegistrationService(client: client)
        sut?.register(user: testUser()){capturedResult.append($0)}
        
        sut = nil
        
        client.complete(withStatusCode: 200, data: makeJSON(jsonFor()))
        XCTAssertTrue(capturedResult.isEmpty)
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RegistrationService, client: HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RegistrationService(client: client)
        
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        
        return (sut, client)
    }
    
    private struct TestRequest: Codable {
        public let email: String
        public let password: String
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
    
    private func makeRegistrationResponse(id: String, email: String, createdAt: (date: Date, iso8601String: String), updatedAt: (date: Date, iso8601String: String))
    -> (model: RegistrationResponse, json: [String: Any])
    {
        let item = RegistrationResponse(id: id, email: email, createdAt: createdAt.date, updatedAt: updatedAt.date)
        
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
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
    }
    
    private func makeErrorJSON(_ message: String = "") -> Data {
        let json = ["message": message]
        return try! JSONSerialization.data(withJSONObject: json)
        
    }
    
    private func expect(_ sut: RegistrationService, registering user: RegistrationRequest, toCompleteWith expectedResult: RegistrationService.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
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
