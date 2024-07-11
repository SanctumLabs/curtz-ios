//
//  LoginViewModel.swift
//  CurtzAllTests
//
//  Created by George Nyakundi on 11/07/2024.
//

import Foundation
import Curtz

enum LoginViewState {
    case idle
    case authenticating
    case hasError(Error)
}

class LoginViewModel: ObservableObject {
    @Published var state: LoginViewState = .idle
    
    private let authService: AuthService
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func login(with username: String, password: String) {
        let loginRequest = LoginRequest(email: username, password: password)
        
        DispatchQueue.main.async {[weak self] in
            guard let self else { return }
            
            self.state = .authenticating
            authService.login(user: loginRequest) { result in
                switch result {
                case let .success(loginResponse):
                    print(loginResponse.accessToken)
                    self.state = .idle
                case let .failure(error):
                    self.state = .hasError(error)
                }
            }
        }
    }
}
