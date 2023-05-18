//
//  CurtziOSApp.swift
//  CurtziOS
//
//  Created by George Nyakundi on 11/08/2022.
//

import SwiftUI

@main
struct CurtziOSApp: App {
    
    let appViewModel: CurtziOSAppViewModel
    
    init() {
        appViewModel = CurtziOSAppViewModel()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                LoginView()
            }.environmentObject(appViewModel)
        }
    }
}
