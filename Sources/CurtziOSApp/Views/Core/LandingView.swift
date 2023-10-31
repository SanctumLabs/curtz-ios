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
    @Binding var loggedInSuccessfully: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Text("Curtz")
                .font(.largeTitle)
            Spacer()
            VStack {
                Button(action: {
                    withAnimation {
                        isLogin = true
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
                    withAnimation {
                        isRegistering = true
                    }
                }) {
                    Text("Register")
                        .frame(maxWidth: 300)
                }
                .buttonStyle(.plain)
                .controlSize(.large)
            }
            .padding([.bottom,], 20)
            .fullScreenCover(isPresented: $isLogin, content: {
                LoginView(dismiss: $isLogin, loggedInSuccessfully: $loggedInSuccessfully)
            })
            .fullScreenCover(isPresented: $isRegistering, onDismiss: { isRegistering.toggle()}, content: {
                RegisterView(dismiss: $isRegistering)
            })
            
        }
    }
}

#Preview {
    LandingView(loggedInSuccessfully: .constant(false))
}
