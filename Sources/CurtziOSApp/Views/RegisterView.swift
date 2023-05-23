//
//  RegisterView.swift
//  CurtzAllTests
//
//  Created by George Nyakundi on 09/04/2023.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var vm: CurtziOSAppViewModel
    
    @State var email: String = ""
    @State var password: String = ""
    @State var hasError: Bool = false
    @State var errorMessage: String = ""
    @State var hasCompletedSuccessfully: Bool = false
    
    var body: some View {
            VStack(alignment: .leading, spacing: 15) {
                Text("Register")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                if hasError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                if hasCompletedSuccessfully {
                    Text("Account created successfully 🎉")
                        .foregroundColor(.green)
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
                    vm.register(user: email, password: password) { result in
                        switch result {
                        case .success:
                            hasCompletedSuccessfully = true
                        case let .failure(error):
                            hasError = true
                            errorMessage = error.localizedDescription
                        }
                    }
                }
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                NavigationLink(destination: LoginView()) {
                    Text("Already have an account?")
                        .font(.caption)
                        .fontWeight(.thin)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                }
                Spacer()
                Text("By creating an account, you agree to Curtz's Conditions of Use and Private Notice.")
                    .font(.caption)
                    .fontWeight(.thin)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .navigationTitle("Curtz")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
            .navigationBarBackButtonHidden()
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {        
            RegisterView()
        }
    }
}
