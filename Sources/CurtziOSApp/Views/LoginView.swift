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
    @Binding var dismiss: Bool
    @Binding var loggedInSuccessfully: Bool
    
    @FocusState private var emailTextFieldFocussed: Bool
    @FocusState private var passwordTextFieldFocussed: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading) {
                HStack {
                    Button {
                        withAnimation {
                            dismiss = false
                        }
                        
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
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
                        loggedInSuccessfully = true
                        dismiss = true
                    }
                }
            }, label: {
                Text("Continue")
                    .foregroundColor(Color.LightIcon)
                    .padding([.vertical], 18)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 30, style: .continuous).fill(Color.DarkBackground))
            })
            .padding([.top], 8)

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
        LoginView(dismiss: .constant(false), loggedInSuccessfully: .constant(false))
    }
}
