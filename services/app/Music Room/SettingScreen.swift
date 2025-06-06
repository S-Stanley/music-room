//
//  SettingScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 09/04/2025.
//

import SwiftUI

struct SettingScreen: View {
    @StateObject var usersViewModel = UsersViewModel()
    @StateObject var settingsScreenViewModel = SettingsScreenViewModel()
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
                    settingsScreenViewModel.selectedUserId = user.id
                    settingsScreenViewModel.sendInvitation()
                }) {
                    VStack(alignment: .leading) {
                        Text(user.email)
                        Text(user.id)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }

            if settingsScreenViewModel.isAdmin() {
                Divider()
                Text("Créer une session de vote (Admin seulement)")
                    .font(.headline)

                TextField("Adresse (ex: Paris)", text: $settingsScreenViewModel.address)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                DatePicker("Date de début", selection: $settingsScreenViewModel.startDate, displayedComponents: [.date])
                    .datePickerStyle(.compact)
                
                DatePicker("Date de fin", selection: $settingsScreenViewModel.endDate, displayedComponents: [.date])
                    .datePickerStyle(.compact)

                Button("Lancer la session") {
                    settingsScreenViewModel.createVotingSession()
                }
                .buttonStyle(.borderedProminent)
            }


            if let message = settingsScreenViewModel.message {
                Text(message)
                    .foregroundColor(.gray)
                    .padding()
            }

            Spacer()
        }
        .padding()
        .onAppear {
            usersViewModel.fetchUsers()
            settingsScreenViewModel.playlistId = playlistId
            settingsScreenViewModel.creatorUserName = creatorUserName
        }
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
