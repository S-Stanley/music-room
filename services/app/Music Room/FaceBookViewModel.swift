//
//  FaceBookViewModel.swift
//  Music Room
//
//  Created by Nathan Bechon on 12/05/2025.
//

import SwiftUI
import FacebookLogin

class FaceBookViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var userEmail = ""

    func signInWithFacebook() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["email", "public_profile"], from: nil) { result, error in
            if let error = error {
                print("❌ Erreur Facebook Login: \(error.localizedDescription)")
                return
            }

            guard let result = result, !result.isCancelled else {
                print("❗ Connexion Facebook annulée")
                return
            }

            guard let accessToken = AccessToken.current?.tokenString else {
                print("❌ Pas de token Facebook")
                return
            }

            print("✅ Token Facebook obtenu : \(accessToken)")

            // 👉 Envoie ce token à ton backend :
            self.sendFacebookTokenToBackend(accessToken)
        }
    }

    func sendFacebookTokenToBackend(_ token: String) {
        let url = URL(string: "http://localhost:5001/users/facebook/auth/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "token=\(token)"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Erreur backend: \(error)")
                return
            }
            DispatchQueue.main.async {
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Réponse invalide")
                    return
                }
                switch httpResponse.statusCode {
                case 200:
                    if let data = data {
                        do {
                            let response = try JSONDecoder().decode(SignInResponse.self, from: data)
                            if let id = response.id, let email = response.email, let token = response.token, let name = response.name {
                                let user = User(id: id, email: email, token: token, name: name)
                                user.save()

                                print("✅ Utilisateur connecté via facebook : \(email)")

                                // MAJ de l'état de ton ViewModel si nécessaire
                                DispatchQueue.main.async {
                                    self.userEmail = email
                                    self.isAuthenticated = true
                                }
                            } else {
                                print("⚠️ Réponse incomplète du serveur")
                            }
                        } catch {
                            print("❌ Erreur lors du décodage : \(error.localizedDescription)")
                        }
                    }
                case 400:
                    print("❌ Requête invalide")
                case 500:
                    print("🔥 Erreur serveur")
                default:
                    print("❗️Code HTTP inattendu : \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
    
    func linkFacebookAccount() {
            let loginManager = LoginManager()
            loginManager.logIn(permissions: ["email", "public_profile"], from: nil) { result, error in
                if let error = error {
                    print("❌ Erreur Facebook Login: \(error.localizedDescription)")
                    return
                }

                guard let result = result, !result.isCancelled else {
                    print("❗ Connexion Facebook annulée")
                    return
                }

                guard let accessToken = AccessToken.current?.tokenString else {
                    print("❌ Pas de token Facebook")
                    return
                }

                print("✅ Token Facebook obtenu : \(accessToken)")

                // 🔗 Envoie pour linking (pas pour login)
                self.sendFacebookTokenToBackendLink(accessToken)
            }
        }

        private func sendFacebookTokenToBackendLink(_ facebookToken: String) {
            guard let url = URL(string: "http://localhost:5001/users/facebook/auth") else {
                print("❌ URL invalide")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

            // ✅ Ajout du token utilisateur dans le header
            if let userToken = User.load()?.token {
                request.setValue(userToken, forHTTPHeaderField: "Token")
            } else {
                print("⚠️ Aucun token utilisateur trouvé (non connecté ?)")
            }

            let body = "token=\(facebookToken)"
            request.httpBody = body.data(using: .utf8)

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ Erreur réseau : \(error.localizedDescription)")
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse else {
                        print("❌ Réponse invalide")
                        return
                    }

                    switch httpResponse.statusCode {
                    case 200:
                        if let data = data {
                            do {
                                let response = try JSONDecoder().decode(SignInResponse.self, from: data)
                                if let id = response.id, let email = response.email, let token = response.token, let name = response.name {
                                    let user = User(id: id, email: email, token: token, name: name)
                                    user.save()

                                    print("✅ Compte Facebook lié pour : \(email)")

                                    self.userEmail = email
                                    self.isAuthenticated = true
                                } else {
                                    print("⚠️ Réponse incomplète")
                                }
                            } catch {
                                print("❌ Erreur de décodage : \(error.localizedDescription)")
                            }
                        }
                    case 400:
                        print("❌ Requête invalide")
                    case 500:
                        print("🔥 Erreur serveur")
                    default:
                        print("❗️Code HTTP inattendu : \(httpResponse.statusCode)")
                    }
                }
            }.resume()
        }
}
