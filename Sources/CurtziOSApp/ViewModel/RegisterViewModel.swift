//
//  RegisterViewModel.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 11/07/2024.
//

import Curtz
import Foundation

enum RegisterViewState {
    case idle
    case registering
    case hasError(Error)
}

protocol RegisterViewDelegate {
    func dismissRegisterView()
}

class RegisterViewModel: ObservableObject {
    @Published var state: RegisterViewState = .idle
    private let service: RegistrationService
    private let delegate: RegisterViewDelegate
    
    init(registrationService: RegistrationService, delegate: RegisterViewDelegate) {
        self.service = registrationService
        self.delegate = delegate
    }
    
    func register(with email: String, password: String){
        let request = RegistrationRequest(email: email, password: password)
        
        DispatchQueue.main.async {[weak self] in
            guard let self else { return }
            
            self.state = .registering
            service.register(user: request) { result in
                switch result {
                case .success:
                    self.state = .idle
                    self.delegate.dismissRegisterView()
                case let .failure(error):
                    self.state = .hasError(error)
                }
            }
        }
    }
}
