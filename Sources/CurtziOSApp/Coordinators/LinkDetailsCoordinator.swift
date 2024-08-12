//
//  EditNewLinkCoordinator.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 12/08/2024.
//

import Foundation
import UIKit
import Curtz
import SwiftUI

final class LinkDetailsCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private let coreService: CoreService
    private let shortenedURL: ShortenedURL
    
    init(navigationController: UINavigationController, service: CoreService, shortenedURL: ShortenedURL) {
        self.navigationController = navigationController
        self.coreService = service
        self.shortenedURL = shortenedURL
    }
    
    func start() {
        let vm = LinkDetailsViewModel(service: coreService, shortenedURL: shortenedURL)
        vm.delegate = self
        let view = LinkDetailsView(vm: vm)
        let viewHC = UIHostingController(rootView: view)
        navigationController.pushViewController(viewHC, animated: true)
    }
}

extension LinkDetailsCoordinator: LinkDetailsDelegate {
    func didFinishTapped() {
        navigationController.popViewController(animated: true)
    }
}
