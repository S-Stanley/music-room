//
//  SettingScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 09/04/2025.
//

import SwiftUI

struct SettingScreen: View {
    @StateObject var usersViewModel = UsersViewModel()
    @State private var selectedUserId: String?
    @State private var message: String?
    @State private var address: String = ""

    let playlistId: String
    let creatorUserName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .bold()

            Text("Inviter un utilisateur à la playlist")
                .font(.title3)

            List(usersViewModel.users) { user in
                Button(action: {
                    selectedUserId = user.id
                    sendInvitation()
                }) {
                    VStack(alignment: .leading) {
                        Text(user.email)
                        Text(user.id)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }

            if isAdmin() {
                Divider()
                Text("Créer une session de vote (Admin seulement)")
                    .font(.headline)

                TextField("Adresse (ex: Paris)", text: $address)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Lancer la session") {
                    createVotingSession()
                }
                .buttonStyle(.borderedProminent)
            }

            if let message = message {
                Text(message)
                    .foregroundColor(.gray)
                    .padding()
            }

            Spacer()
        }
        .padding()
        .onAppear {
            usersViewModel.fetchUsers()
        }
    }

    // MARK: - Vérifie si l'utilisateur courant est le créateur (admin)
    func isAdmin() -> Bool {
        guard let user = User.load() else { return false }
        return user.name == creatorUserName
    }

    // MARK: - Envoi d'une invitation
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
                    message = "Erreur : \(error.localizedDescription)"
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 201:
                        message = "✅ Invitation envoyée à \(selectedUserId)"
                    case 400:
                        message = "❌ Données invalides"
                    default:
                        message = "🔥 Erreur serveur (\(httpResponse.statusCode))"
                    }
                }
            }
        }.resume()
    }

    // MARK: - Créer une session de vote
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

        // 🕒 Simplicité : start et end mis à l'année courante pour l'exemple
        let year = Calendar.current.component(.year, from: Date())
        let body = "start=\(year)&end=\(year)&addr=\(address)"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    message = "Erreur : \(error.localizedDescription)"
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        message = "✅ Session de vote créée à l'adresse « \(address) »"
                    case 400:
                        message = "❌ Adresse invalide ou format date incorrect"
                    default:
                        message = "🔥 Erreur serveur (\(httpResponse.statusCode))"
                    }
                }
            }
        }.resume()
    }
}

struct UserModel: Identifiable, Codable {
    let id: String
    let email: String
    // Ajoute d’autres infos si dispo (username, etc.)
}

class UsersViewModel: ObservableObject {
    @Published var users: [UserModel] = []
    
    func fetchUsers() {
        guard let user = User.load(),
              let url = URL(string: "http://localhost:5001/users/?take=50&skip=0") else { return }

        var request = URLRequest(url: url)
        request.setValue(user.token, forHTTPHeaderField: "token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    do {
                        let users = try JSONDecoder().decode([UserModel].self, from: data)
                        self.users = users
                    } catch {
                        print("❌ JSON decode error:", error)
                    }
                } else if let error = error {
                    print("❌ Network error:", error)
                }
            }
        }.resume()
    }
}
