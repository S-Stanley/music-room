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


    func loadUserInfo() {
        if let token = UserDefaults.standard.string(forKey: "auth_token"), !token.isEmpty {
            self.isAuthenticated = true
            self.email = UserDefaults.standard.string(forKey: "user_email") ?? "Email non trouvé"
        }
    }

    // Méthode pour la connexion (signIn)
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
                    if let data = data {
                        let responseString = String(data: data, encoding: .utf8)
                        print("Réponse brute: \(responseString ?? "")")

                        // Tentative de décodage
                        let decoder = JSONDecoder()
                        do {
                            let response = try decoder.decode(SignInResponse.self, from: data)
                            // Stocke le token et mets à jour l'état de l'authentification
                            UserDefaults.standard.set(response.token, forKey: "auth_token")
                            UserDefaults.standard.set(response.email, forKey: "user_email")
                            self.isAuthenticated = true
                            self.email = response.email ?? "Email non trouvé"
                        } catch {
                            self.errorMessage = "Erreur lors de la décodification de la réponse : \(error.localizedDescription)"
                            print("Erreur lors de la décodification: \(error.localizedDescription)")
                        }
                    }
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
                        // Enregistrer l'email et token dans UserDefaults après inscription
                        UserDefaults.standard.set(self.email, forKey: "user_email")
                        UserDefaults.standard.set("dummyToken", forKey: "auth_token") // Remplacer par le token réel si disponible
                        self.email = self.email // Mise à jour de l'email affiché
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

struct SignInResponse: Codable {
    let id: String?
    let email: String?
    let token: String?
    let error: String?
}
