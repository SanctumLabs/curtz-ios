//
//  LoginView.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 09/04/2023.
//

import SwiftUI

struct LoginView: View {
    @State var email: String = ""
    @State var password: String = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            TextField("Email address", text: $email)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.blue, lineWidth: 1)
                }
            TextField("Password", text: $password)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.blue, lineWidth: 1)
                }
            
            Button("Continue") {
                
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            NavigationLink(destination: RegisterView()) {
                Text("Don't have an account?, Create one")
                    .font(.caption)
                    .fontWeight(.thin)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .navigationTitle("Curtz")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
        .navigationBarBackButtonHidden()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
