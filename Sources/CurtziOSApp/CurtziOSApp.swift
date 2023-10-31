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
    @State var loggedInSuccessfully: Bool = false
    
    init() {
        appViewModel = CurtziOSAppViewModel()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if loggedInSuccessfully {
                    DashboardView(loggedIn: $loggedInSuccessfully)
                } else {
                    LandingView(loggedInSuccessfully: $loggedInSuccessfully)
                }
                
            }.environmentObject(appViewModel)
        }
    }
}
