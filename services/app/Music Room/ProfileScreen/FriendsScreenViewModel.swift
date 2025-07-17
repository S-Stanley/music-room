//
//  FriendsScreenViewModel.swift
//  Music Room
//
//  Created by Nathan Bechon on 27/06/2025.
//

import Foundation
import Combine

struct FriendRequest: Codable, Identifiable {
    let id: String
    let requestedById: String
    let invitedUserId: String
    let state: String
    let createdAt: String
}

struct FriendRelationship: Codable, Identifiable {
    let id: String
    let createdAt: String
    let friend: UserSummary
}

struct UserInfo: Codable, Identifiable {
    let id: String
    let email: String
    let musicType: String
}

class FriendsScreenViewModel: ObservableObject {
    @Published var allUsers: [UserSummary] = []
    @Published var receivedRequests: [FriendRequest] = []
    @Published var errorMessage: String?
    @Published var friends: [UserSummary] = []
    @Published var userInfos: [String: UserInfo] = [:]
    @Published var invitationStatuses: [String: String] = [:]


    private var baseURL = "http://localhost:5001"

        func fetchAllUsers() {
            guard let url = URL(string: "\(baseURL)/users") else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            guard let user = User.load() else {
                self.errorMessage = "Utilisateur non connecté"
                return
            }
            request.setValue(user.token, forHTTPHeaderField: "token")

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    guard let data = data,
                          let status = (response as? HTTPURLResponse)?.statusCode,
                          status == 200 else {
                        self.errorMessage = "Erreur serveur"
                        return
                    }
                    
                    do {
                        self.allUsers = try JSONDecoder().decode([UserSummary].self, from: data)
                    } catch {
                        self.errorMessage = "Décodage échoué"
                    }
                }
            }.resume()
        }
    
    func fetchUserInfo(userId: String) {
        guard let url = URL(string: "\(baseURL)/users/\(userId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        guard let user = User.load() else {
            self.errorMessage = "Utilisateur non connecté"
            return
        }

        request.setValue(user.token, forHTTPHeaderField: "token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Erreur info user: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("❌ Réponse invalide pour infos utilisateur")
                    return
                }

                guard let data = data else {
                    print("❌ Pas de données pour infos utilisateur")
                    return
                }

                do {
                    let info = try JSONDecoder().decode(UserInfo.self, from: data)
                    self.userInfos[userId] = info
                } catch {
                    print("❌ Erreur de décodage UserInfo: \(error.localizedDescription)")
                }
            }
        }.resume()
    }

    
    func fetchFriends() {
        guard let url = URL(string: "\(baseURL)/friends") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        guard let user = User.load() else {
            self.errorMessage = "Utilisateur non connecté"
            return
        }

        request.setValue(user.token, forHTTPHeaderField: "token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Erreur réseau: \(error.localizedDescription)"
                    return
                }

                // ✅ Vérification du code HTTP
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Réponse invalide du serveur"
                    return
                }
                
                guard httpResponse.statusCode == 200 else {
                    self.errorMessage = "Erreur serveur: \(httpResponse.statusCode)"
                    print("❌ Code de statut HTTP:", httpResponse.statusCode)
                    return
                }

                guard let data = data else {
                    self.errorMessage = "Aucune donnée reçue"
                    return
                }

                print("🔍 Réponse brute amis:", String(data: data, encoding: .utf8) ?? "nil")

                do {
                    let relationships = try JSONDecoder().decode([FriendRelationship].self, from: data)
                    self.friends = relationships.map { $0.friend }

                    // 🔁 Récupération des infos supplémentaires de chaque ami
                    for friend in self.friends {
                        self.fetchUserInfo(userId: friend.id)
                    }
                } catch {
                    self.errorMessage = "Erreur de décodage des amis: \(error.localizedDescription)"
                }
            }
        }.resume()
    }


    func sendFriendRequest(to invitedUserId: String) {
        guard let url = URL(string: "\(baseURL)/friends/invitation") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        guard let user = User.load() else {
            DispatchQueue.main.async {
                self.errorMessage = "Utilisateur non connecté"
            }
            return
        }

        request.setValue(user.token, forHTTPHeaderField: "token")
        request.httpBody = "invitedUserId=\(invitedUserId)".data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, _ in
            DispatchQueue.main.async {
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { return }

                switch statusCode {
                case 201:
                    if let data = data {
                        do {
                            let request = try JSONDecoder().decode(FriendRequest.self, from: data)
                            self.invitationStatuses[request.invitedUserId] = request.state
                            print("✅ Invitation envoyée avec état : \(request.state)")
                            self.errorMessage = nil
                        } catch {
                            self.errorMessage = "Erreur de décodage"
                        }
                    }

                case 400:
                    self.errorMessage = "Utilisateur introuvable"
                case 500:
                    self.errorMessage = "Erreur serveur"
                default:
                    self.errorMessage = "Erreur \(statusCode)"
                }
            }
        }.resume()
    }



    func fetchFriendRequests() {
        guard let url = URL(string: "http://localhost:5001/friends/invitation") else {
            self.errorMessage = "URL invalide"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        guard let user = User.load() else {
            self.errorMessage = "Utilisateur non connecté"
            return
        }

        request.setValue(user.token, forHTTPHeaderField: "token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Erreur: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Réponse invalide"
                    return
                }

                guard httpResponse.statusCode == 200 else {
                    self.errorMessage = "Erreur serveur ou requête non trouvée: \(httpResponse.statusCode)"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "Aucune donnée reçue"
                    return
                }

                do {
                    let requests = try JSONDecoder().decode([FriendRequest].self, from: data)
                    self.receivedRequests = requests
                } catch {
                    self.errorMessage = "Décodage échoué: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    func acceptRequest(id: String) {
            guard let url = URL(string: "\(baseURL)/friends/invitation/accept") else { return }
            guard let user = User.load() else {
                self.errorMessage = "Utilisateur non connecté"
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue(user.token, forHTTPHeaderField: "token")
            request.httpBody = "request_id=\(id)".data(using: .utf8)

            URLSession.shared.dataTask(with: request) { _, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = "Erreur: \(error.localizedDescription)"
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse else {
                        self.errorMessage = "Réponse invalide"
                        return
                    }

                    if httpResponse.statusCode == 200 {
                        print("Invitation accepté")
                        self.receivedRequests.removeAll { $0.id == id }
                        self.fetchFriends()
                    } else {
                        self.errorMessage = "Erreur \(httpResponse.statusCode) lors de l'acceptation"
                    }
                }
            }.resume()
        }

        func declineRequest(id: String) {
            guard let url = URL(string: "\(baseURL)/friends/invitation/decline") else { return }
            guard let user = User.load() else {
                self.errorMessage = "Utilisateur non connecté"
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue(user.token, forHTTPHeaderField: "token")
            request.httpBody = "request_id=\(id)".data(using: .utf8)

            URLSession.shared.dataTask(with: request) { _, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = "Erreur: \(error.localizedDescription)"
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse else {
                        self.errorMessage = "Réponse invalide"
                        return
                    }

                    if httpResponse.statusCode == 200 {
                        self.receivedRequests.removeAll { $0.id == id }
                        print("Invitation refusé")
                    } else {
                        self.errorMessage = "Erreur \(httpResponse.statusCode) lors du refus"
                    }
                }
            }.resume()
        }
}
