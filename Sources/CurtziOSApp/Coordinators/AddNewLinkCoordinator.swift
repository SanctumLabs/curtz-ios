//
//  AddNewLinkCoordinator.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 30/07/2024.
//

import Foundation
import UIKit
import SwiftUI
import Curtz

final class AddNewLinkCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    private let coreService: CoreService
    
    init(navigationController: UINavigationController, service: CoreService) {
        self.navigationController = navigationController
        self.coreService = service
    }
    
    func start() {
        let vm = AddNewLinkViewModel(coreService: coreService)
        vm.delegate = self
        let view = AddNewLinkView(vm: vm)
        let viewHC = UIHostingController(rootView: view)
        
        navigationController.pushViewController(viewHC, animated: true)
    }
}

extension AddNewLinkCoordinator: AddNewLinkDelegate {
    func didTapClose() {
        navigationController.popViewController(animated: true)
    }
}
