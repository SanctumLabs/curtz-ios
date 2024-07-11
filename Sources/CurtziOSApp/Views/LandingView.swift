//
//  LandingView.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 11/07/2024.
//

import SwiftUI

struct LandingView: View {
    var loginAction: (() -> Void)?
    var registerAction: (() -> Void)?
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Button(action: { loginAction?() }, label: {
                    Text("Login")
                })
                Divider()
                Button(action: { registerAction?() }, label: {
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
