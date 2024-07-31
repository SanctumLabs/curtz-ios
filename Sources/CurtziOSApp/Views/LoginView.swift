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
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
            
            VStack(alignment: .leading) {
                Text("Email")
                HStack {
                    Image(systemName: "character")
                        .foregroundColor(.gray).font(.headline)
                    TextField("Enter your email", text: $email)
                        .textInputAutocapitalization(.never)
                        .disabled(vm.state == .authenticating)
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 0.5))
            }
            VStack(alignment: .leading) {
                Text("Password")
                HStack {
                    Image(systemName: "eye.slash")
                        .foregroundColor(.gray).font(.headline)
                    SecureField("Enter your password", text: $password)
                        .textInputAutocapitalization(.never)
                        .disabled(vm.state == .authenticating)
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 0.5))
            }
            .padding([.bottom], 14)
            Button(action: {
                vm.login(with: email, password: password)
            }, label: {
                if vm.state == .authenticating {
                    ProgressView()
                } else {
                    Text("Login")
                        .font(.headline)
                }
            })
            .frame(width: 360, height: 50)
            .background(email.isEmpty || password.isEmpty || vm.state == .authenticating ? .gray : .blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .disabled(email.isEmpty || password.isEmpty || vm.state == .authenticating)
            Spacer()
        }
        .padding()
    }
}
//
//#Preview {
//    LoginView()
//}
