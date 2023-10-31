//
//  LandingView.swift
//  CurtzAllTests
//
//  Created by George Nyakundi on 30/10/2023.
//

import SwiftUI

struct LandingView: View {
    
    @State var isLogin: Bool = false
    @State var isRegistering: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            Text("Curtz")
                .font(.largeTitle)
            Spacer()
            VStack {
                Button(action: {
                    withAnimation {
                        isLogin.toggle()
                    }
                }, label: {
                    Text("Login")
                        .frame(maxWidth: 300)
                })
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding([.bottom], 20)
                
                Button(action: {
                    isRegistering.toggle()
                }) {
                    Text("Register")
                        .frame(maxWidth: 300)
                }
                .buttonStyle(.plain)
                .controlSize(.large)
            }
            .padding([.bottom,], 20)
            .fullScreenCover(isPresented: $isLogin, content: {
                LoginView(dismiss: $isLogin)
            })
            .fullScreenCover(isPresented: $isRegistering, onDismiss: { isRegistering.toggle()}, content: {
                RegisterView()
            })
            
        }
    }
}

#Preview {
    LandingView()
}
