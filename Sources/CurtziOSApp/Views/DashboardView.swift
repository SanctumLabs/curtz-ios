//
//  DashboardView.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 13/04/2023.
//

import SwiftUI

enum DashboardTab: String {
    case home = "Home"
    case settings = "Settings"
}

struct DashboardView: View {
    @EnvironmentObject var vm: CurtziOSAppViewModel
    @State private var successFullyLogout = false
    
    @State var activeTab: String = DashboardTab.home.rawValue
    @State var ctaSelected: Bool = false
    @Binding var loggedIn: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $activeTab,
                    content:  {
                HomeView()
                    .tag(DashboardTab.home.rawValue)
                SettingsView(loggedIn: $loggedIn)
                    .tag(DashboardTab.settings.rawValue)
            })
            CustomTabBar(currentTab: $activeTab, ctaSelected: $ctaSelected)
        }
        .fullScreenCover(isPresented: $ctaSelected, content: {
            ShortenerView(ctaSelected: $ctaSelected)
        })
        
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashboardView(loggedIn: .constant(false))
        }
    }
}

struct CurtzURL: Equatable {
    let id: String
    let originalUrl: String
    let customAlias: String
    let expiresOn: Date
    let keywords: [String]
    let userId: String
    let shortCode: String
    let createdAt: Date
    let updatedAt: Date
    let hits: Int
}
