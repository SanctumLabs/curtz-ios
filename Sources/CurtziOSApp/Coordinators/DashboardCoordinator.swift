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
    private var dashboardViewModel: DashboardViewModel?
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
        let vm = SettingViewModel()
        
        let settingsView = SettingsView(vm: vm)
        let settingsViewHC = UIHostingController(rootView: settingsView)
        let settingsVC = UINavigationController(rootViewController: settingsViewHC)
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))
        settingsVC.navigationBar.topItem?.title = "Settings"
        
        tabBarController.viewControllers = [dashboardTab(), settingsVC]
        // Hides the extra navigationBar
        navigationController.navigationBar.isHidden = true
        navigationController.setViewControllers([tabBarController], animated: true)
    }
    
}

extension DashboardCoordinator {
    private func dashboardTab() -> UINavigationController {
        let coreService = CoreService(serviceURL: CurtzEndpoint.fetchAll.url(baseURL: baseURL) , client: authenticatedClient)
        let dashboardViewModel = DashboardViewModel(coreService: coreService)
        dashboardViewModel.delegate = self
        let dashboardView = DashboardView(vm: dashboardViewModel)
        
        let dashboardViewHC = UIHostingController(rootView: dashboardView)
        let dashboardVC = UINavigationController(rootViewController: dashboardViewHC)
        dashboardViewHC.title = "Dashboard"
        dashboardViewHC.navigationController?.navigationBar.prefersLargeTitles = true
        dashboardViewHC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: dashboardViewModel, action: #selector(dashboardViewModel.didTapAdd))
        dashboardViewHC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: dashboardViewModel, action: #selector(dashboardViewModel.didTapRefresh))
        dashboardVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"),selectedImage: UIImage(systemName: "house.fill"))
        return dashboardVC
    }
}

extension DashboardCoordinator: DashboardViewDelegate {
    func didFinishAddNewLink() {
        navigationController.popViewController(animated: true)
    }
    
    func didTapAddNewLink() {
        let coreService = CoreService(serviceURL: CurtzEndpoint.shorten.url(baseURL: baseURL) , client: authenticatedClient)
        let addNewLinkCoordinator = AddNewLinkCoordinator(navigationController: navigationController, service: coreService)
        childCoordinators.append(addNewLinkCoordinator)
        addNewLinkCoordinator.start()
    }
}
