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

protocol LoginViewDelegate {
    func didDismissLoginView()
}

class LoginViewModel: ObservableObject {
    @Published var state: LoginViewState = .idle
    
    private let authService: AuthService
    private let delegate: LoginViewDelegate
    
    init(authService: AuthService, delegate: LoginViewDelegate) {
        self.authService = authService
        self.delegate = delegate
    }
    
    func login(with username: String, password: String) {
        let loginRequest = LoginRequest(email: username, password: password)
        
        DispatchQueue.main.async {[weak self] in
            guard let self else { return }
            
            self.state = .authenticating
            authService.login(user: loginRequest) { result in
                switch result {
                case .success:
//                    self.state = .idle
                    self.delegate.didDismissLoginView()
                case let .failure(error):
                    self.state = .hasError(error)
                }
            }
        }
    }
}
