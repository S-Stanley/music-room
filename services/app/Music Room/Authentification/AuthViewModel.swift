//
//  AuthViewModel.swift
//  Music Room
//
//  Created by Nathan Bechon on 07/03/2025.
//

import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false

    func signIn(email: String, password: String) {
        guard let url = URL(string: "http://localhost:5001/users/email/signin") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "email=\(email)&password=\(password)"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Erreur: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Réponse invalide du serveur")
                    return
                }

                print("Statut HTTP:", httpResponse.statusCode)

                if httpResponse.statusCode == 200 {
                    print("Connexion réussie !")
                    self.isAuthenticated = true  // ✅ Change l'état global
                } else {
                    print("Erreur d'authentification")
                }
            }
        }.resume()
    }
}

