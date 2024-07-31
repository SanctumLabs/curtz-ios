//
//  ErrorView.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 30/07/2024.
//

import SwiftUI

struct ErrorView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "exclamationmark.bubble")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .padding([.bottom], 15)
                .foregroundStyle(.red)
            Text("Something has gone wrong. Please try again later")
                .font(.body)
                .lineLimit(2)
        }
        .padding()
    }
}

#Preview {
    ErrorView()
}
