//
//  LoginView.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 09/04/2023.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var vm: CurtziOSAppViewModel
    
    @State var email: String = ""
    @State var password: String = ""
    @State var hasError: Bool = false
    @State private var successFullyAuthenticated = false
    @Binding var dismiss: Bool
    
    @FocusState private var emailTextFieldFocussed: Bool
    @FocusState private var passwordTextFieldFocussed: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading) {
                HStack {
                    Button {
                        dismiss.toggle()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    Spacer()
                    Text("Login")
                    Spacer()
                }
            }
            
            if hasError {
                Text("Couldn't login, please try again")
                    .foregroundColor(.red)
            }
            VStack(alignment: .leading) {
                Text("Email address")
                    .foregroundStyle(emailTextFieldFocussed ? .blue : .black)
                TextField("Email address", text: $email)
                    .padding()
                    .focused($emailTextFieldFocussed)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(emailTextFieldFocussed ? .blue: .black, lineWidth: 1)
                    }
            }
            VStack(alignment: .leading) {
                Text("Password")
                    .foregroundStyle(passwordTextFieldFocussed ? .blue : .black)
                SecureField("Password", text: $password)
                    .padding()
                    .focused($passwordTextFieldFocussed)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(passwordTextFieldFocussed ? .blue: .black, lineWidth: 1)
                    }
            }
            
            Button(action: {
                passwordTextFieldFocussed = false
                emailTextFieldFocussed = false
                vm.login(user: email, password: password) { result in
                    switch result {
                    case .failure:
                        hasError = true
                    case .success:
                        successFullyAuthenticated = true
                    }
                }
            }, label: {
                Text("Continue")
                    .frame(maxWidth: 340)
            })
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .frame(maxWidth: .infinity)
            .disabled(email.isEmpty && password.isEmpty)
            Spacer()
        }
        .navigationTitle("Curtz")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
        .navigationBarBackButtonHidden()
    }
    
    private func clearFields() {
        email = ""
        password = ""
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(dismiss: .constant(false))
    }
}
