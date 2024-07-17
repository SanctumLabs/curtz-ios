//
//  Coordinator.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 17/07/2024.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}
