//
//  LoginView.swift
//  CurtzAllTests
//
//  Created by George Nyakundi on 11/07/2024.
//

import SwiftUI

struct LoginView: View {
    @State var email: String = ""
    @State var password: String = ""
    @ObservedObject private var vm: LoginViewModel
    
    init(vm: LoginViewModel) {
        self.vm = vm
    }
    var body: some View {
        VStack {
            if case .hasError  = vm.state {
                Text("Something went wrong")
            }
            
            VStack(alignment: .leading) {
                Text("Email")
                HStack {
                    Image(systemName: "character")
                        .foregroundColor(.gray).font(.headline)
                    TextField("Enter your email", text: $email)
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 0.5))
            }
            VStack(alignment: .leading) {
                Text("Password")
                HStack {
                    Image(systemName: "eye.slash")
                        .foregroundColor(.gray).font(.headline)
                    TextField("Enter your password", text: $password)
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 0.5))
            }
            Button(action: {
                vm.login(with: email, password: password)
            }, label: {
                Text("Login")
                    .font(.headline)
            })
            .frame(width: 250, height: 50)
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .disabled(email.isEmpty || password.isEmpty || vm.state == .authenticating)
        }
        .padding()
    }
}
//
//#Preview {
//    LoginView()
//}
