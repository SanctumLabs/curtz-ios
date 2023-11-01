//
//  SettingsView.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 26/10/2023.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vm: CurtziOSAppViewModel
    
    @Binding var loggedIn: Bool
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Divider()
            Button(action: {
                withAnimation {
                    vm.logout()
                    //TODO: - Have one source of truth
                    loggedIn = false
                }
            }, label: {
                Text("Log out")
            })
            .buttonStyle(BouncyButton(duration: 0.3, scale: 0.6))
            .padding([.bottom], 20)
        }
        .padding()
    }
}

#Preview {
    SettingsView(loggedIn: .constant(false))
}
