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
    
    public typealias ShorteningResult = ShortenResult
    public typealias FetchResult = Result<[ShortenResponseItem], Error>
    
    public enum Error: Swift.Error {
        case malformedRequest
        case invalidResponse
        case clientError(String)
    }
    
    public init(serviceURL: URL, client: HTTPClient) {
        self.serviceURL = serviceURL
        self.client = client
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
}

extension CoreService.Error: Equatable { }
