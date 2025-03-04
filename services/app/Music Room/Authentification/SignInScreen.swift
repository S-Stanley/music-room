//
//  SignUpScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 15/12/2024.
//

import SwiftUI

struct SignInScreen: View {
    @State private var email: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Welcome back,")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Good to see you again")
                .foregroundColor(Color.gray)
                .padding(.bottom, 40)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: signIn) {
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

    func signIn() {
        guard let url = URL(string: "http://localhost:5001/users/email/signin") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "email=\(email)"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Erreur: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Réponse invalide du serveur"
                    return
                }

                if httpResponse.statusCode == 200 {
                    print("Connexion réussie !")
                } else if httpResponse.statusCode == 400 {
                    self.errorMessage = "L'email n'existe pas ou est invalide"
                } else {
                    self.errorMessage = "Erreur inconnue (\(httpResponse.statusCode))"
                }
            }
        }.resume()
    }
}

#Preview {
    SignInScreen()
}
