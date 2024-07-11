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

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var state: RegisterViewState = .idle
    private let service: RegistrationService
    
    init(registrationService: RegistrationService) {
        self.service = registrationService
    }
    
    func register(with email: String, password: String){
        let request = RegistrationRequest(email: email, password: password)
        
        DispatchQueue.main.async {[weak self] in
            guard let self else { return }
            
            self.state = .registering
            service.register(user: request) { result in
                switch result {
                case let .success(res):
                    print(res.createdAt)
                    self.state = .idle
                case let .failure(error):
                    self.state = .hasError(error)
                }
            }
        }
    }
}
