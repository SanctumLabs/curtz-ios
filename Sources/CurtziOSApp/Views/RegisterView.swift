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
            if case let .hasError(error) = vm.state {
                Text("\(error.localizedDescription)")
            }
            
            TextField(text: $username) {
                Text("Email")
            }
            .textInputAutocapitalization(.never)
            .padding([.bottom])
            Divider()
            SecureField(text: $password) {
                Text("Password")
            }
            
            Button {
                vm.register(with: username, password: password)
            } label: {
                Text("Register")
            }
            .disabled(username.isEmpty || password.isEmpty)
        }
        .padding([.leading, .trailing])
    }
}

//#Preview {
//    RegisterView()
//}
