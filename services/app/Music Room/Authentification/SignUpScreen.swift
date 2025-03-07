//
//  SignUpScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 15/12/2024.
//

import SwiftUI

struct SignUpScreen: View {
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        VStack {
            TextField("Email", text: $authViewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            SecureField("Mot de passe", text: $authViewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: authViewModel.signUp) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
