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
                    DashboardListView(
                        items: items,
                        onDelete: { item in vm.delete(item) },
                        onEdit: { item in vm.edit(item) }
                    )
                } else {
                    EmptyStateView(createAction: vm.didTapAdd)
                        .padding([.top], 18)
                }
            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(2.0, anchor: .center)
            case .hasError:
                ErrorView()
            }
        }.onAppear(perform: {
            vm.load()
        })
    }
}
