//
//  SettingsView.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 18/07/2024.
//

import SwiftUI

protocol SettingsViewDelegate {
    func didTapLogout()
}

final class SettingViewModel: ObservableObject {
    
    var delegate: SettingsViewDelegate?
    
    func appVersion() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    func currentYear() -> String {
        Calendar.current.dateComponents([.year], from: .now).year?.description ?? ""
    }
    
    func logout() {
        delegate?.didTapLogout()
    }
}

struct SettingsView: View {
    @ObservedObject var vm: SettingViewModel
    
    init(vm: SettingViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        VStack {
            Text("About Curtz")
                .font(.headline.bold())
                .padding()
            Text("The Curtz iOS app is a sample project designed to demonstrate best practices for structuring and developing iOS applications. We encourage you to explore the codebase to learn from its implementation.")
                .bold()
            Spacer(minLength: 20)
            Button {
                vm.logout()
            } label: {
                Text("Logout")
                    .foregroundStyle(.red)
            }
            
            VStack {
                Text("Sanctum Labs \(vm.currentYear())")
                Text("v\(vm.appVersion())")
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    SettingsView(vm: SettingViewModel())
}
