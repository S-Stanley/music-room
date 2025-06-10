//
//  SettingsScreenViewModel.swift
//  Music Room
//
//  Created by Nathan Bechon on 03/06/2025.
//

import Foundation

class SettingsScreenViewModel: ObservableObject {
    @Published var selectedUserId: String?
    @Published var message: String?
    @Published var address: String = ""
    @Published var startDate = Date()
    @Published var endDate = Date()
    
    @Published var playlistId: String = ""
    @Published var creatorUserName: String = ""

    
    func isAdmin() -> Bool {
        guard let user = User.load() else { return false }
        return user.name == creatorUserName
    }

    func sendInvitation() {
        guard let user = User.load(), let selectedUserId = selectedUserId else {
            message = "Utilisateur non authentifié ou utilisateur non sélectionné"
            return
        }

        guard let url = URL(string: "http://localhost:5001/playlist/\(playlistId)/invitations") else {
            message = "URL invalide"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(user.token, forHTTPHeaderField: "token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "userId=\(selectedUserId)"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.message = "Erreur : \(error.localizedDescription)"
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 201:
                        self.message = "✅ Invitation envoyée à \(selectedUserId)"
                    case 400:
                        self.message = "❌ Données invalides"
                    default:
                        self.message = "🔥 Erreur serveur (\(httpResponse.statusCode))"
                    }
                }
            }
        }.resume()
    }

    func createVotingSession() {
        guard let user = User.load() else {
            message = "Utilisateur non authentifié"
            return
        }

        guard let url = URL(string: "http://localhost:5001/playlist/\(playlistId)/edit/session") else {
            message = "URL invalide"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(user.token, forHTTPHeaderField: "token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy" // Ex: "20 November 2025"
        formatter.locale = Locale(identifier: "en_US_POSIX") // Pour s'assurer du format anglais

        let startFormatted = formatter.string(from: startDate)
        let endFormatted = formatter.string(from: endDate)

        let body = "start=\(startFormatted)&end=\(endFormatted)&addr=\(address)"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.message = "Erreur : \(error.localizedDescription)"
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        self.message = "✅ Session de vote créée à l'adresse « \(self.address) »"
                    case 400:
                        self.message = "❌ Adresse invalide ou format date incorrect"
                    default:
                        self.message = "🔥 Erreur serveur (\(httpResponse.statusCode))"
                    }
                }
            }
        }.resume()
    }
}
