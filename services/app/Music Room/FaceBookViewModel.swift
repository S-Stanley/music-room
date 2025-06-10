//
//  FaceBookViewModel.swift
//  Music Room
//
//  Created by Nathan Bechon on 12/05/2025.
//

import FBSDKLoginKit

class FaceBookViewModel: ObservableObject {
    @Published var userEmail: String = ""
    @Published var isAuthenticated: Bool = false

    func signInWithFacebook() {
        guard let rootVC = UIApplication.shared.windows.first?.rootViewController else {
            print("❌ Pas de rootViewController")
            return
        }
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["email", "public_profile"], from: rootVC) { result, error in
            if let error = error {
                print("❌ Erreur Facebook Login: \(error.localizedDescription)")
                return
            }

            guard let result = result, !result.isCancelled else {
                print("❗ Connexion Facebook annulée")
                return
            }

            if let tokenString = AccessToken.current?.tokenString {
                print("✅ Token Facebook obtenu: \(tokenString)")
                // Tu peux envoyer ce token à ton backend ici
            } else {
                print("❌ Pas de token Facebook après login")
            }
        }
    }


    func signOut() {
        LoginManager().logOut()
        self.isAuthenticated = false
        self.userEmail = ""
    }

    private func sendTokenToBackend(token: String) {
        guard let url = URL(string: "http://localhost:5001/users/facebook/auth") else {
            print("❌ URL invalide")
            return
        }

        print("🔑 Facebook AccessToken envoyé: \(token)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "token=\(token)"
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

                                print("✅ Utilisateur connecté via Facebook : \(email)")

                                // MAJ de l'état
                                self.userEmail = email
                                self.isAuthenticated = true
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
}

