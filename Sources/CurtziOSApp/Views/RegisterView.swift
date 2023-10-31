//
//  RegisterView.swift
//  CurtzAllTests
//
//  Created by George Nyakundi on 09/04/2023.
//

import SwiftUI
import Curtz

struct RegisterView: View {
    @EnvironmentObject var vm: CurtziOSAppViewModel
    
    @State var email: String = ""
    @State var password: String = ""
    @State var hasError: Bool = false
    @State var errorMessage: String = ""
    @State var hasCompletedSuccessfully: Bool = false
    
    @Binding var dismiss: Bool
    
    @FocusState private var emailTextFieldFocussed: Bool
    @FocusState private var passwordTextFieldFocussed: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, content: {
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
                    Text("Register")
                    Spacer()
                }
            })
            
            if hasError {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            if hasCompletedSuccessfully {
                Text("Account created successfully 🎉")
                    .foregroundColor(.green)
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
                hasError = false
                hasCompletedSuccessfully = false
                vm.register(user: email, password: password) { result in
                    switch result {
                    case .success:
                        hasCompletedSuccessfully = true
                        dismiss = false
                        clearFields()
                    case let .failure(error as RegistrationService.Error):
                        hasError = true
                        switch error {
                        case let .clientError(errorMsg):
                            errorMessage = errorMsg
                            
                        default:
                            errorMessage = "Please try again"
                        }
                    default:
                        hasError = true
                        errorMessage = "Something went wrong 😭"
                    }
                }
            }, label: {
                Text("Continue")
                    .frame(maxWidth: 340)
            }).buttonStyle(.borderedProminent)
                .controlSize(.large)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .frame(maxWidth: .infinity)
                .disabled(email.isEmpty && password.isEmpty)
            
            Spacer()
            Text("By creating an account, you agree to Curtz's Conditions of Use and Private Notice.")
                .font(.caption)
                .fontWeight(.thin)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding()
        .navigationBarBackButtonHidden()
    }
    
    private func clearFields() {
        email = ""
        password = ""
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RegisterView(dismiss: .constant(false))
        }
    }
}
