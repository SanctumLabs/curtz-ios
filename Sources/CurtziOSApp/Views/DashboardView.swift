//
//  DashboardView.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 18/07/2024.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject private var vm: DashboardViewModel
    
    init(vm: DashboardViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        VStack {
            switch vm.state {
            case .loaded(let items):
                if !items.isEmpty {
                    Text("\(items.count)")
                } else {
                    Text("Add shortened urls")
                }
            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(2.0, anchor: .center)
            case .hasError(let error):
                Text("\(error.localizedDescription)")
            }
        }.onAppear(perform: {
            vm.load()
        })
    }
}
