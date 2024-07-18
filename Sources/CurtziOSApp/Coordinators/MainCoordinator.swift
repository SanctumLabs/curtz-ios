//
//  MainCoordinator.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 17/07/2024.
//

import UIKit
import SwiftUI
import Curtz

final class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    let urlSessionHTTPClient = URLSessionHTTPClient()
    let baseURL = URL(string: "http://localhost:8085")!
    let store = SecureStore()
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        // Check if a valid token exists, then navigate to Dashboard
        
        // Otherwise navigate to the LandingView
        let landingView = LandingView(coordinator: self)
        let vc = UIHostingController(rootView: landingView)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func navigateToLogin() {
        let authService = composeAuthService()
        let loginViewModel = LoginViewModel(authService: authService, delegate: self)
        let hostingController = UIHostingController(rootView: LoginView(vm: loginViewModel))
        navigationController.pushViewController(hostingController, animated: true)
    }
    
    func navigateToRegister() {
        let registrationService = composeRegistrationService()
        let registerViewModel = RegisterViewModel(registrationService: registrationService, delegate: self)
        let hostingController = UIHostingController(rootView: RegisterView(vm: registerViewModel))
        navigationController.pushViewController(hostingController, animated: true)
    }
    
    func navigateToDashboard() {
        let dashboardCoordinator = DashboardCoordinator(navigationController: navigationController)
        childCoordinators.append(dashboardCoordinator)
        dashboardCoordinator.start()
    }
}

// MARK: Composition Layer
extension MainCoordinator {
    private func composeRegistrationService() -> RegistrationService {
        let registationURL = CurtzEndpoint.register.url(baseURL: baseURL)
        let registrationService = RegistrationService(registrationURL: registationURL, client: urlSessionHTTPClient)
        return registrationService
    }
}

extension MainCoordinator {
    private func composeAuthService() -> AuthService {
        let loginURL: URL = CurtzEndpoint.login.url(baseURL: baseURL)
        let storeManager = CurtzStoreManager(with: store)
        let authService = AuthService(loginURL: loginURL, client: urlSessionHTTPClient, storeManager: storeManager)
        return authService
    }
}

// MARK: - Delegate Conformance
extension MainCoordinator: LoginViewDelegate {
    func didDismissLoginView() {
        DispatchQueue.main.async {[weak self] in
            self?.navigateToDashboard()
        }
    }
}

extension MainCoordinator: RegisterViewDelegate {
    func dismissRegisterView() {
        navigateToLogin()
    }
}
