//
//  AppCoordinator.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 18/04/2024.
//

import UIKit

final class AppCoordinator: Coordinator {
    private let window: UIWindow
    
    var childCoordinators: [any Coordinator] = []
    
    var navigationController: UINavigationController
    
    init(_ window: UIWindow, navigationController: UINavigationController) {
        self.window = window
        self.navigationController = navigationController
    }
    
    init(_ scene: UIWindowScene, navigationController: UINavigationController) {
        self.window = UIWindow(windowScene: scene)
        self.navigationController = navigationController
    }
    
    func start() {
        let destination = OnboardingViewController()
        navigationController.viewControllers = [destination]
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
