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
    @Published var shouldNavigateToForgotPassword = false
    
    func loadUserInfo() {
        if let savedUser = User.load() {
            self.isAuthenticated = true
            self.email = savedUser.email
            print("🔄 Utilisateur chargé: \(savedUser.email)")
        } else {
            self.isAuthenticated = false
            self.email = ""
            print("⚠️ Aucun utilisateur trouvé")
        }
    }

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

                switch httpResponse.statusCode {
                case 200:
                    if let data = data {
                        do {
                            let response = try JSONDecoder().decode(SignInResponse.self, from: data)
                            if let id = response.id, let email = response.email, let token = response.token, let name = response.name { // Récupérer le nom
                                let user = User(id: id, email: email, token: token, name: name) // Inclure le nom
                                user.save()

                                print("✅ Utilisateur enregistré :", email)

                                DispatchQueue.main.async {
                                    self.isAuthenticated = true
                                    self.email = email
                                }
                            } else {
                                self.errorMessage = "Réponse incomplète du serveur"
                            }
                        } catch {
                            self.errorMessage = "Erreur lors du décodage de la réponse"
                            print("❌ Erreur de décodage: \(error.localizedDescription)")
                        }
                    }
                case 400:
                    self.errorMessage = "Email ou mot de passe invalide"
                default:
                    self.errorMessage = "Erreur inconnue (\(httpResponse.statusCode))"
                }
            }
        }.resume()
    }

    func signUp(completion: @escaping () -> Void) {
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
                    print("✅ Utilisateur inscrit")
                    completion() // 🔥 On déclenche l'affichage de la pop-up
                case 400:
                    self.errorMessage = "Cet email est déjà utilisé ❌"
                default:
                    self.errorMessage = "Erreur inconnue (\(httpResponse.statusCode))"
                }
            }
        }.resume()
    }

    func validateEmail(code: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://localhost:5001/users/email/validate") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "email=\(email)&confirmationCode=\(code)"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Erreur: \(error.localizedDescription)"
                    completion(false)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Réponse invalide"
                    completion(false)
                    return
                }

                if httpResponse.statusCode == 200 {
                    print("✅ Email confirmé")
                    self.signIn()
                } else {
                    self.errorMessage = "Code invalide ou expiré"
                }
            }
        }.resume()
    }

}

struct SignInResponse: Codable {
    let id: String?
    let email: String?
    let token: String?
    let name: String?
    let error: String?
}
