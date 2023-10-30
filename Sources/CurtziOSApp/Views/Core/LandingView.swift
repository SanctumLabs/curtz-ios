//
//  LandingView.swift
//  CurtzAllTests
//
//  Created by George Nyakundi on 30/10/2023.
//

import SwiftUI

struct LandingView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Curtz")
                .font(.largeTitle)
            Spacer()
            VStack {
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Text("Login")
                        .frame(maxWidth: 300)
                })
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding([.bottom], 20)
                
                Button(action: {}) {
                    Text("Register")
                        .frame(maxWidth: 300)
                }
                .buttonStyle(.plain)
                .controlSize(.large)
            }
            .padding([.bottom,], 20)
        }
    }
}

#Preview {
    LandingView()
}
