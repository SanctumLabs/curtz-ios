//
//  LoginViewModel.swift
//  CurtzAllTests
//
//  Created by George Nyakundi on 11/07/2024.
//

import Foundation
import Curtz

enum LoginViewState: Equatable {
    case idle
    case processing
    case hasError
}

protocol LoginViewDelegate {
    func didDismissLoginView()
}

final class LoginViewModel: ObservableObject {
    @Published var state: LoginViewState = .idle
    
    private let authService: AuthService
    private let delegate: LoginViewDelegate
    
    init(authService: AuthService, delegate: LoginViewDelegate) {
        self.authService = authService
        self.delegate = delegate
    }
    
    func login(with username: String, password: String) {
        let loginRequest = LoginRequest(email: username, password: password)
        self.state = .processing
        
        authService.login(user: loginRequest) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {[weak self] in
                    self?.delegate.didDismissLoginView()
                }
            case .failure:
                DispatchQueue.main.async {[weak self] in
                    self?.state = .hasError
                }
               
            }
        }
    }
}
