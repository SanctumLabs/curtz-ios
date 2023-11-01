//
//  CurtziOSAppViewModel.swift
//  curtz-ios
//
//  Created by George Nyakundi on 18/05/2023.
//

import Foundation
import Curtz

class CurtziOSAppViewModel: ObservableObject {
    
    private let storeManager: StoreManager
    private let tokenService: TokenService
    private let httpClient: HTTPClient
    private let authenticatedHTTPClient: HTTPClient
    private let authService: AuthService
    private let registrationService: RegistrationService
    
    // FOR Local Development
    private let baseURL: URL = URL(string: "http://localhost:8085")!
    
    init() {
        storeManager = CurtzStoreManager(with: SecureStore())
        tokenService = CurtzTokenService(storeManager: storeManager)
        httpClient = URLSessionHTTPClient()
        authenticatedHTTPClient = AuthenticatedHTTPClientDecorater(decoratee: httpClient, tokenService: tokenService)
        
        authService = AuthService(loginURL: CurtzEndpoint.login.url(baseURL: baseURL), client: httpClient, storeManager: storeManager)
        registrationService = RegistrationService(registrationURL: CurtzEndpoint.register.url(baseURL: baseURL), client: httpClient)
    }
    
    
    func login(user: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let loginRequest = LoginRequest(email: user, password: password)
        authService.login(user: loginRequest) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            default:
                completion(.success(()))
            }
        }
    }
    
    func logout() {
        authService.logout()
    }
    
    func register(user: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let registrationRequest = RegistrationRequest(email: user, password: password)
        registrationService.register(user: registrationRequest) { result in
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
}
