//
//  Coordinator.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 18/04/2024.
//

import UIKit

/// Conform to this protocol to perform navigation activities
protocol Coordinator: AnyObject {
    /// The Child Coordinators
    var childCoordinators: [Coordinator] { get set }
    
    /// The navigation controller
    var navigationController: UINavigationController { get }
    
    /// Main entry point
    func start()
}

extension Coordinator {
    
    /// Adds a child coordinator
    /// - Parameter coordinator: the coordinator to be added
    func addChild(_ coordinator: Coordinator) {
        if !childCoordinators.contains(where: { $0 === coordinator }) {
            childCoordinators.append(coordinator)
        }
    }
    
    /// Removes a child coordinator
    /// - Parameter coordinator: the coordinator to be removed
    func removeChild(_ coordinator: Coordinator) {
        if let index = childCoordinators.firstIndex(where: { $0 === coordinator }) {
            childCoordinators.remove(at: index)
        }
    }
    
    /// Adds a child coordinator and starts it
    /// - Parameter coordinator: coordinator to add and start
    func startChild(_ coordinator: Coordinator) {
        addChild(coordinator)
        coordinator.start()
    }
}
