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
        if let user = User.load() {
            self.isAuthenticated = true
            self.email = user.email
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
                            let decoder = JSONDecoder()
                            do {
                                let response = try decoder.decode(SignInResponse.self, from: data)
                                if let id = response.id, let email = response.email, let token = response.token {
                                    let user = User(id: id, email: email, token: token)
                                    user.save()
                                    print("Utilisateur enregistré :", User.load() ?? "Aucun utilisateur trouvé")

                                    self.isAuthenticated = true
                                    self.email = email
                                }
                            } catch {
                                self.errorMessage = "Erreur lors du décodage de la réponse"
                                print("Erreur de décodage: \(error.localizedDescription)")
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
                        
                        if let data = data {
                            let decoder = JSONDecoder()
                            do {
                                let response = try decoder.decode(SignInResponse.self, from: data)
                                UserDefaults.standard.set(response.email, forKey: "user_email")
                                UserDefaults.standard.set(response.token, forKey: "auth_token")
                                UserDefaults.standard.set(response.id, forKey: "user_id")
                                self.email = response.email ?? "Email non trouvé"
                            } catch {
                                self.errorMessage = "Erreur lors du décodage de la réponse"
                                print("Erreur de décodage: \(error.localizedDescription)")
                            }
                        }
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
    
    //PAS ENCORE UTILE
    func fetchUserProfile() {
        guard let user = User.load() else {
            self.errorMessage = "Utilisateur non authentifié"
            return
        }

        guard let url = URL(string: "http://localhost:5001/users/\(user.id)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(user.token, forHTTPHeaderField: "token")
        print("Envoi du token :", user.token)
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Erreur: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                    self.errorMessage = "Impossible de récupérer les infos utilisateur"
                    return
                }

                do {
                    let userInfo = try JSONDecoder().decode(SignInResponse.self, from: data)
                    self.email = userInfo.email ?? "Email inconnu"
                } catch {
                    self.errorMessage = "Erreur de décodage"
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
