//
//  DashboardCoordinator.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 18/07/2024.
//

import UIKit
import SwiftUI
import Curtz

final class DashboardCoordinator: Coordinator {
    private let authenticatedClient: HTTPClient
    private let baseURL: URL
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController, client: HTTPClient, tokenService: TokenService, baseURL: URL) {
        self.navigationController = navigationController
        self.authenticatedClient = AuthenticatedHTTPClientDecorater(decoratee: client, tokenService: tokenService)
        self.baseURL = baseURL
        
    }
 
    func start() {
        // Create a UITabBarController
        let tabBarController = UITabBarController()
        
        let settingsView = SettingsView()
        let settingsViewHC = UIHostingController(rootView: settingsView)
        let settingsVC = UINavigationController(rootViewController: settingsViewHC)
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))
        
        tabBarController.viewControllers = [dashboardTab(), settingsVC]
        navigationController.setViewControllers([tabBarController], animated: true)
    }
    
}

extension DashboardCoordinator {
    private func dashboardTab() -> UINavigationController {
        let coreService = CoreService(serviceURL: CurtzEndpoint.fetchAll.url(baseURL: baseURL) , client: authenticatedClient)
        let dashboardViewModel = DashboardViewModel(coreService: coreService, delegate: self)
        let dashboardView = DashboardView(vm: dashboardViewModel)
        
        let dashboardViewHC = UIHostingController(rootView: dashboardView)
        let dashboardVC = UINavigationController(rootViewController: dashboardViewHC)
        dashboardVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"),selectedImage: UIImage(systemName: "house.fill"))
        return dashboardVC
    }
}

extension DashboardCoordinator: DashboardViewDelegate {}
