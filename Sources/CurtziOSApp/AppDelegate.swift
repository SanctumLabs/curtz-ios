//
//  AppDelegate.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 18/04/2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow()
        window?.rootViewController = MainViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
}
