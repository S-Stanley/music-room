//
//  AuthViewModel.swift
//  Music Room
//
//  Created by Nathan Bechon on 07/03/2025.
//

import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false

    func signIn() {
        guard let url = URL(string: "http://localhost:5001/users/email/signin") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "email=\(email)&password=\(password)"
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
                    self.isAuthenticated = true
                } else if httpResponse.statusCode == 400 {
                    self.errorMessage = "Email ou mot de passe invalide"
                } else {
                    self.errorMessage = "Erreur inconnue (\(httpResponse.statusCode))"
                }
            }
        }.resume()
    }
    
    func signUp() {
        
        guard !email.isEmpty, !password.isEmpty else {
                    self.errorMessage = "Veuillez remplir tous les champs."
                    return
                }
        
        guard let url = URL(string: "http://localhost:5001/users/email/signup") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "email=\(email)&password=\(password)"
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

                switch httpResponse.statusCode {
                    case 201:
                        print("Inscription réussie ✅")
                        self.isAuthenticated = true
                    case 400:
                        self.errorMessage = "Cet email est déjà utilisé ❌"
                    case 500:
                        self.errorMessage = "Erreur serveur. Veuillez réessayer plus tard."
                    default:
                        self.errorMessage = "Erreur inconnue (\(httpResponse.statusCode))"
                }
            }
        }.resume()
    }
}


