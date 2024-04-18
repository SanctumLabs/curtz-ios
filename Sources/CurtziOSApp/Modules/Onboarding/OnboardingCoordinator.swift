//
//  OnboardingCoordinator.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 18/04/2024.
//

import UIKit

final class OnboardingCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    func start() {
        // Display the Onboarding views
    }
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}
