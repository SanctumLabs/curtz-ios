//
//  DashboardCoordinator.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 18/07/2024.
//

import UIKit
import SwiftUI

final class DashboardCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
 
    func start() {
        // Create a UITabBarController
        let tabBarController = UITabBarController()
        
        let dashboardView = DashboardView()
        let dashboardViewHC = UIHostingController(rootView: dashboardView)
        let dashboardVC = UINavigationController(rootViewController: dashboardViewHC)
        dashboardVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"),selectedImage: UIImage(systemName: "house.fill"))
        
        let settingsView = SettingsView()
        let settingsViewHC = UIHostingController(rootView: settingsView)
        let settingsVC = UINavigationController(rootViewController: settingsViewHC)
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))
        
        tabBarController.viewControllers = [dashboardVC, settingsVC]
        navigationController.setViewControllers([tabBarController], animated: true)
    }
    
}
