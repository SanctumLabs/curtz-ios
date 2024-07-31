//
//  SettingsView.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 18/07/2024.
//

import SwiftUI

final class SettingViewModel: ObservableObject {
    func appVersion() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    func currentYear() -> String {
        Calendar.current.dateComponents([.year], from: .now).year?.description ?? ""
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
            
            Spacer()
            Text("Sanctum Labs \(vm.currentYear())")
            Text("v\(vm.appVersion())")
        }
        .padding()
    }
}

#Preview {
    SettingsView(vm: SettingViewModel())
}
