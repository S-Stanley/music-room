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
        let url = URL(string: "https://ton-backend.com/api/auth/facebook")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["accessToken": token]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Erreur backend: \(error)")
                return
            }

            // ✅ Ton backend te renvoie un JWT + infos utilisateur
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("✅ Réponse backend: \(json)")
                // Stocker le token et mettre à jour l’état
            }
        }.resume()
    }
}

