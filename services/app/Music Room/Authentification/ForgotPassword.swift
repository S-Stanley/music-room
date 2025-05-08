//
//  ForgotPassword.swift
//  Music Room
//
//  Created by Nathan Bechon on 06/05/2025.
//

import SwiftUI

struct ForgotPassword: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var email: String = ""
    @State private var newPassword: String = ""
    @State private var code: String = ""

    var body: some View {
        VStack(spacing: 24) {
            Text("Mot de passe oublié")
                .font(.title2)
                .bold()

            VStack(alignment: .leading, spacing: 12) {
                Text("Email")
                TextField("Entrez votre adresse email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)

                Text("Nouveau mot de passe")
                SecureField("Entrez un nouveau mot de passe", text: $newPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Envoyer email de réinitialisation") {
                    authViewModel.requestPasswordReset(email: email, newPassword: newPassword) { success in
                        // Optionnel : afficher un feedback
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("Code de confirmation")
                TextField("Entrez le code reçu par email", text: $code)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Confirmer le nouveau mot de passe") {
                    authViewModel.confirmPasswordChange(email: email, code: code) { success in
                        // Optionnel : redirection
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            if !authViewModel.errorMessage2.isEmpty {
                Text(authViewModel.errorMessage2)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            if !authViewModel.successMessage.isEmpty {
                Text(authViewModel.successMessage)
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .onAppear {
            authViewModel.clearMessages()
        }
    }
}
