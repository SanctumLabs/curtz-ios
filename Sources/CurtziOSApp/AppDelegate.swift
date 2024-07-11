//
//  AppDelegate.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 18/04/2024.
//

import UIKit
import SwiftUI
import Curtz

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let urlSessionHTTPClient = URLSessionHTTPClient()
    let baseURL = URL(string: "http://localhost:8085")!
    let store = SecureStore()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow()

//        let navigationController = UINavigationController()
//        var landingView = LandingView(loginAction: {}, registerAction: {})
//        navigationController. = UINavigationController(rootViewController: UIHostingController(rootView: landingView))
//        landingView.loginAction = {
//            let authService = composeAuthService()
//            let loginViewModel = LoginViewModel(authService: authService)
//            let hostingController = UIHostingController(rootView: LoginView(vm: loginViewModel))
//            navigationController.present(hostingController, animated: true)
//        }
//        let hostingController = UIHostingController(rootView: LandingView(loginAction: {
//            
//        }, registerAction: {
//            
//        }))
        let registrationService = composeRegistrationService()
        let registerViewModel = RegisterViewModel(registrationService: registrationService)
        let hostingController = UIHostingController(rootView: RegisterView(vm: registerViewModel))
        window?.rootViewController = hostingController
        window?.makeKeyAndVisible()
        
        return true
    }
}


// MARK: Composition Layer
extension AppDelegate {
    private func composeRegistrationService() -> RegistrationService {
        let registationURL = CurtzEndpoint.register.url(baseURL: baseURL)
        let registrationService = RegistrationService(registrationURL: registationURL, client: urlSessionHTTPClient)
        return registrationService
    }
}


extension AppDelegate {
    private func authService() -> AuthService {
        let loginURL: URL = CurtzEndpoint.login.url(baseURL: baseURL)
        let storeManager = CurtzStoreManager(with: store)
        let authService = AuthService(loginURL: loginURL, client: urlSessionHTTPClient, storeManager: storeManager)
        return authService
    }
}
