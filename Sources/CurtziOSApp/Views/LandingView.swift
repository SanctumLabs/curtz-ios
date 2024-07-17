//
//  LandingView.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 11/07/2024.
//

import SwiftUI

struct LandingView: View {
    var coordinator: MainCoordinator?
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Button(action: {
                    coordinator?.navigateToLogin()
                }, label: {
                    Text("Login")
                })
                Divider()
                Button(action: {  
                    coordinator?.navigateToRegister()
                }, label: {
                    Text("Register")
                })  
            }
            Spacer()
        }
    }
}

//#Preview {
//    LandingView()
//}
