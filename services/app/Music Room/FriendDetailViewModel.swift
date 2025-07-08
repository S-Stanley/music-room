//
//  FriendDetailViewModel.swift
//  Music Room
//
//  Created by Nathan Bechon on 04/07/2025.
//

import Foundation

class FriendDetailViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var musicType: String = ""
    @Published var email: String = ""
    @Published var name: String = ""
    @Published var isAuthenticated: Bool = false
    
    func loadFriendInfo() {
        if let savedUser = User.load() {
            self.isAuthenticated = true
            self.email = savedUser.email
            self.name = savedUser.name
            print("🔄 Utilisateur chargé: \(savedUser.email)")
            
            // 🔽 Ajout : appel à l’API pour récupérer musicType
            guard let url = URL(string: "http://localhost:5001/users/\(savedUser.id)") else {
                self.errorMessage = "URL invalide"
                return
            }
            
            var request = URLRequest(url: url)
            request.setValue(savedUser.token, forHTTPHeaderField: "token")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = "Erreur: \(error.localizedDescription)"
                        return
                    }

                    guard let data = data else {
                        self.errorMessage = "Aucune donnée reçue"
                        return
                    }

                    do {
                        // Tu peux faire un `print(String(data: data, encoding: .utf8))` ici pour debugger
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let musicType = json["musicType"] as? String {
                            self.musicType = musicType.uppercased()
                        } else {
                            self.errorMessage = "Format de réponse invalide"
                        }
                    } catch {
                        self.errorMessage = "Erreur de décodage JSON: \(error.localizedDescription)"
                    }
                }
            }.resume()
            
        } else {
            self.isAuthenticated = false
            self.email = ""
            self.name = ""
            print("⚠️ Aucun utilisateur trouvé")
        }
    }
}
