//
//  ProfileViewModel.swift
//  Music Room
//
//  Created by Nathan Bechon on 26/03/2025.
//

import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var invitations: [Invitation] = []

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

    
    func updateEmail(newEmail: String) {
        guard let user = User.load() else {
            self.errorMessage = "Utilisateur non authentifié"
            return
        }
        
        guard let url = URL(string: "http://localhost:5001/users/info") else {
            self.errorMessage = "URL invalide"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(user.token, forHTTPHeaderField: "token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "email=\(newEmail)"
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
                        print("Email mis à jour avec succès ✅")
                        self.email = newEmail // Mettre à jour l'interface utilisateur
                        
                        // Sauvegarde les nouvelles infos de l'utilisateur
                    let updatedUser = User(id: user.id, email: newEmail, token: user.token, name: user.name)
                        updatedUser.save()
                    
                    case 400:
                        self.errorMessage = "Email invalide ou déjà utilisé"
                    
                    case 401:
                        self.errorMessage = "Non autorisé. Vérifiez votre token d'authentification."
                    
                    default:
                        self.errorMessage = "Erreur inconnue (\(httpResponse.statusCode))"
                }
            }
        }.resume()
    }
    
    func updatePassword(newPassword: String) {
        guard let user = User.load() else {
            self.errorMessage = "Utilisateur non authentifié"
            return
        }
        
        guard let url = URL(string: "http://localhost:5001/users/info") else {
            self.errorMessage = "URL invalide"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(user.token, forHTTPHeaderField: "token") // Envoi du token dans l'en-tête
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "password=\(newPassword)"
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
                        print("Mot de passe mis à jour avec succès ✅")
                        self.password = newPassword
                        
                        // Sauvegarde les nouvelles infos de l'utilisateur (même si ici c'est juste le mot de passe)
                    let updatedUser = User(id: user.id, email: user.email, token: user.token, name: user.name)
                        updatedUser.save()
                    
                    case 400:
                        self.errorMessage = "Mot de passe invalide"
                    
                    case 401:
                        self.errorMessage = "Non autorisé. Vérifiez votre token d'authentification."
                    
                    default:
                        self.errorMessage = "Erreur inconnue (\(httpResponse.statusCode))"
                }
            }
        }.resume()
    }
    
    func fetchInvitations() {
        guard let user = User.load() else { return }

        guard let url = URL(string: "http://localhost:5001/users/invitations") else { return }

        var request = URLRequest(url: url)
        request.setValue(user.token, forHTTPHeaderField: "token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    let jsonString = String(data: data, encoding: .utf8)
                    print("📦 JSON reçu : \(jsonString ?? "nil")")
                    
                    do {
                        self.invitations = try JSONDecoder().decode([Invitation].self, from: data)
                    } catch {
                        print("Erreur de décodage: \(error)")
                    }
                } else if let error = error {
                    print("Erreur réseau: \(error)")
                }
            }
        }.resume()
    }
}

struct Invitation: Codable, Identifiable {
    let id: String
    let playlist: Playlist
    let invitedBy: UserSummary

    var playlistName: String {
        playlist.name
    }

    var inviterUsername: String {
        invitedBy.name
    }
}

struct Playlist: Codable {
    let id: String
    let name: String
    let type: String
    let password: String?
    let orderType: String
}

struct UserSummary: Codable {
    let id: String
    let name: String
}

