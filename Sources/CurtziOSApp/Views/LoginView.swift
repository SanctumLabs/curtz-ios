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
                
            TextField(text: $email) {
                Text("Email")
            }
            .textInputAutocapitalization(.never)
            Divider()
            SecureField(text: $password) {
                Text("Password")
            }
            Button {
                vm.login(with: email, password: password)
            } label: {
                Text("Login")
            }
            .buttonStyle(.borderedProminent)
            .disabled(email.isEmpty || password.isEmpty || vm.state == .authenticating)

        }
        .padding()
    }
}
//
//#Preview {
//    LoginView()
//}
