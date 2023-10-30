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

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            if hasError {
                Text("Couldn't login, please try again")
                    .foregroundColor(.red)
            }
            TextField("Email address", text: $email)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.blue, lineWidth: 1)
                }
            SecureField("Password", text: $password)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.blue, lineWidth: 1)
                }
            
            Button("Continue") {
                vm.login(user: email, password: password) { result in
                    switch result {
                    case .failure:
                        hasError = true
                    case .success:
                        successFullyAuthenticated = true
                    }
                }
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(email.isEmpty && password.isEmpty)
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
        LoginView()
    }
}
