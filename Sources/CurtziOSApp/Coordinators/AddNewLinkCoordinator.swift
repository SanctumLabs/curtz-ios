//
//  AddNewLinkCoordinator.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 30/07/2024.
//

import Foundation
import UIKit
import SwiftUI

final class AddNewLinkCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vm = AddNewLinkViewModel()
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
