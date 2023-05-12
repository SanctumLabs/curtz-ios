//
//  CurtzStoreManager.swift
//  CurtzUnitTests
//
//  Created by George Nyakundi on 12/05/2023.
//

import Foundation


public final class CurtzStoreManager: StoreManager {
    private let store: Store
    
    public init(with store: Store){
        self.store = store
    }
    
    public func save(_ val: String, forKey key: String, completion: @escaping (SaveResult) -> Void) {
        store.add(val, key: key) {[weak self] result  in
            guard self != nil else { return }
            switch result  {
            case let .failure(error):
                switch error {
                case .failedToSave:
                    completion(.failure(.failedToSave))
                default:
                    completion(.failure(.general(error)))
                }
            default:
                completion(.success(()))
            }
        }
    }
    
    public func retrieveValue(forKey key: String, completion: @escaping(RetrieveResult) -> Void){
        store.search(forKey: key) {[weak self] result in
            guard self != nil else { return }
            switch result {
            case let .failure(error):
                switch error {
                case .notFound:
                    completion(.failure(.notFound))
                default:
                    completion(.failure(.general(error)))
                }
            case let .success(retrievedValue):
                completion(.success(retrievedValue))
            }
        }
    }
    
    public func update(_ val: String, forKey key: String, completion: @escaping(UpdateResult) -> Void) {
        store.update(val, forKey: key) {[weak self] result in
            guard self != nil else { return }
            switch result {
            case let .failure(error):
                switch error {
                case .failedToUpdate:
                    completion(.failure(.failedToUpdate))
                default:
                    completion(.failure(.general(error)))
                }
            case .success:
                completion(.success(()))
            }
        }
    }
    
    
    public func removeValue(forKey key: String, completion: @escaping(DeleteResult) -> Void){
        store.deleteValue(key: key) {[weak self] result in
            guard self != nil else { return }
            switch result {
            case let .failure(error):
                switch error {
                case .failedToDelete:
                    completion(.failure(.failedToRemove))
                default:
                    completion(.failure(.general(error)))
                }
            case .success:
                completion(.success(()))
            }
        }
    }
}
