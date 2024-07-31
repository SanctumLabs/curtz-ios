//
//  RegisterView.swift
//  CurtzAllTests
//
//  Created by George Nyakundi on 11/07/2024.
//

import SwiftUI

struct RegisterView: View {
    @State var username: String = ""
    @State var password: String = ""
    
    @ObservedObject private var vm: RegisterViewModel
    
    init(vm: RegisterViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        VStack {
            if case .hasError = vm.state {
                Text("Something went wrong")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
            
            VStack(alignment: .leading) {
                Text("Email")
                    .foregroundStyle(.gray)
                HStack {
                    Image(systemName: "character")
                        .foregroundColor(.gray).font(.headline)
                    TextField("Enter your email", text: $username)
                        .textInputAutocapitalization(.never)
                        .disabled(vm.state == .processing)
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 0.5))
            }
            VStack(alignment: .leading) {
                Text("Password")
                    .foregroundStyle(.gray)
                HStack {
                    Image(systemName: "eye.slash")
                        .foregroundColor(.gray).font(.headline)
                    SecureField("Enter your password", text: $password)
                        .textInputAutocapitalization(.never)
                        .disabled(vm.state == .processing)
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 0.5))
            }
            Button {
                vm.register(with: username, password: password)
            } label: {
                
                if vm.state == .processing {
                    ProgressView()
                } else {
                    Text("Register")
                        .font(.headline)
                }
            }
            .frame(width: 360, height: 50)
            .background(username.isEmpty || password.isEmpty || vm.state == .processing ? .gray : .blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .disabled(username.isEmpty || password.isEmpty || vm.state == .processing)
            Spacer()
        }
        .padding()
    }
}

//#Preview {
//    RegisterView()
//}
