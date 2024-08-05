//
//  CoreService.swift
//  Curtz
//
//  Created by George Nyakundi on 20/11/2023.
//

import Foundation

public final class CoreService {
    private let client: HTTPClient
    private let serviceURL: URL
    private let baseURL: URL
    
    public typealias ShorteningResult = ShortenResult
    public typealias FetchResult = Result<[ShortenResponseItem], Error>
    public typealias DeleteResult = Result<Void, Error>
    
    public enum Error: Swift.Error {
        case malformedRequest
        case invalidResponse
        case serverError(String)
        case clientError(String)
    }
    
    public init(serviceURL: URL, client: HTTPClient, baseURL: URL) {
        self.serviceURL = serviceURL
        self.client = client
        self.baseURL = baseURL
    }
    
    public func shorten(_ request: ShortenRequest, completion: @escaping(ShorteningResult) -> Void) {
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
        ) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(CoreServiceResponseMapper.mapShorteningResponse(data, from: response))
            default:
                completion(.failure(Error.malformedRequest))
            }
        }
    }
    
    public func fetchAll(completion: @escaping(FetchResult) -> Void){
        client.perform(request: .prepared(for: .fetching, with: serviceURL)) {[weak self] result  in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(CoreServiceResponseMapper.mapFetchAllResponse(data, from: response))
            case .failure:
                completion(.failure(.invalidResponse))
            }
        }
    }
    
    public func deleteURL(with id: String, completion: @escaping(DeleteResult) -> Void) {
        client.perform(request: .prepared(for: .deleteURL(id: id), with: baseURL)) {[weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(CoreServiceResponseMapper.mapDeleteEntryResponse(data, from: response))
            case let .failure(error):
                completion(.failure(.serverError(error.localizedDescription)))
            }
        }
    }
    
    public func editURL(with id: String, urlEditRequest: URLEditRequest, completion: @escaping(ShorteningResult) -> Void) {
        client.perform(
            request: .prepared(
                for: .edit(
                    id: id,
                    customAlias: urlEditRequest.customAlias,
                    keywords: urlEditRequest.keywords,
                    expiresOn: urlEditRequest.expiresOn
                ),
                with: baseURL
            )
        ) { result in
            switch result {
            case let .success((data, response)):
                completion(CoreServiceResponseMapper.mapShorteningResponse(data, from: response))
            case let .failure(error):
                completion(.failure(Error.serverError(error.localizedDescription)))
            }
        }
    }
}

extension CoreService.Error: Equatable { }
