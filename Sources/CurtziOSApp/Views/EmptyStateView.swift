//
//  EmptyStateView.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 29/07/2024.
//

import SwiftUI

struct EmptyStateView: View {
    
    init(createAction: (() -> Void)? = nil) {
        self.createAction = createAction
    }
    
    var createAction: (() -> Void)?
    var body: some View {
        VStack {
            Image(systemName: "pencil.and.list.clipboard")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60)
                .padding([.bottom], 24)
            Text("No links created...yet!")
                .font(.headline)
                .padding([.bottom],8)
            Text("Time to take the app on a spin...")
                .font(.footnote)
                .padding([.bottom], 12)
            Button(action: {
                createAction?()
            }, label: {
                Text("Start creating")
                    .font(.headline)
            })
            .frame(width: 250, height: 50)
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(50)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(.foreground, lineWidth: 0.1)
        }
        Spacer()
        
    }
}

#Preview {
    EmptyStateView()
}
