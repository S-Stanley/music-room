//
//  SignUpScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 15/12/2024.
//

import SwiftUI

struct SignInScreen: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Welcome back,")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Good to see you again")
                    .foregroundColor(Color.gray)
                    .padding(.bottom, 40)
                
                TextField("Email", text: $authViewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $authViewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    authViewModel.shouldNavigateToForgotPassword = true
                }) {
                    Text("Forgot password")
                }
                
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: authViewModel.signIn) {
                    Text("Sign in")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
            }
            .padding(.horizontal, 20)
        }
    }
}

