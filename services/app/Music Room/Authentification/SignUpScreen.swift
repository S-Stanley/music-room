//
//  SignUpScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 15/12/2024.
//

import SwiftUI

struct SignUpScreen: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var showConfirmationPopup = false
    @State private var confirmationCode: String = ""

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

            Button(action: {
                authViewModel.signUp {
                    // 🔐 Appel réussi → on affiche la pop-up de confirmation
                    showConfirmationPopup = true
                }
            }) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .sheet(isPresented: $showConfirmationPopup) {
            VStack(spacing: 20) {
                Text("Code de confirmation")
                    .font(.headline)

                TextField("Entrez le code reçu par email", text: $confirmationCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)

                Button("Valider") {
                    authViewModel.validateEmail(code: confirmationCode) { success in
                        if success {
                            showConfirmationPopup = false
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Annuler") {
                    showConfirmationPopup = false
                }
                .foregroundColor(.red)
            }
            .padding()
        }
    }
}

