//
//  HomeViewModel.swift
//  Music Room
//
//  Created by Nathan Bechon on 27/03/2025.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var activeSessions: [Session] = []
    @Published var selectedPlaylistId: String?
    
    func takeToken() -> String {
        guard let user = User.load() else {
            return ("Error")
        }
        return (user.token)
    }
    
    
    func createSession(name: String, type: String, password: String?, adminToken: String, completion: @escaping (Bool, String?) -> Void) {
        guard let user = User.load() else {
            completion(false, nil)
            return
        }
        
        guard let url = URL(string: "http://localhost:5001/playlist/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(user.token, forHTTPHeaderField: "token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var body = "name=\(name)&type=\(type)&adminToken=\(adminToken)"
        if let password = password, type == "PRIVATE" {
            body += "&password=\(password)"
        }
        
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Erreur: \(error.localizedDescription)")
                    completion(false, nil)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    completion(false, nil)
                    return
                }

                if httpResponse.statusCode == 201 {
                    do {
                        let sessionResponse = try JSONDecoder().decode(Session.self, from: data)
                        print("✅ Session créée avec succès, ID: \(sessionResponse.id)")
                        completion(true, sessionResponse.id) // ✅ On retourne l'ID
                    } catch {
                        print("❌ Erreur de décodage JSON: \(error.localizedDescription)")
                        completion(false, nil)
                    }
                } else {
                    print("❌ Erreur serveur: \(httpResponse.statusCode)")
                    completion(false, nil)
                }
            }
        }.resume()
    }


    func fetchActiveSessions(completion: @escaping (Bool, String?) -> Void) {
        guard let user = User.load() else {
            completion(false, "Utilisateur non authentifié")
            return
        }

        guard let url = URL(string: "http://localhost:5001/playlist/?take=50&skip=0") else {
            completion(false, "URL invalide")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(user.token, forHTTPHeaderField: "token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Erreur de requête: \(error.localizedDescription)")
                    completion(false, "Erreur: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    print("❌ Réponse invalide du serveur")
                    completion(false, "Réponse invalide du serveur")
                    return
                }

                print("✅ Statut HTTP: \(httpResponse.statusCode)")
                print("📥 Réponse JSON brute: \(String(data: data, encoding: .utf8) ?? "Aucune donnée")")

                if httpResponse.statusCode == 200 {
                    do {
                        let sessions = try JSONDecoder().decode([Session].self, from: data)
                        self.activeSessions = sessions

                        // ✅ Sélection automatique d'une session si `selectedPlaylistId` est nil
                        if self.selectedPlaylistId == nil, let firstSession = sessions.first {
                            self.selectedPlaylistId = firstSession.id
                            print("✅ Session sélectionnée automatiquement: \(self.selectedPlaylistId!)")
                        }

                        completion(true, nil)
                    } catch {
                        print("❌ Erreur de décodage JSON: \(error.localizedDescription)")
                        completion(false, "Erreur de décodage JSON")
                    }
                } else {
                    print("❌ Erreur serveur: \(httpResponse.statusCode)")
                    completion(false, "Erreur serveur (\(httpResponse.statusCode))")
                }
            }
        }.resume()
    }
}

struct Session: Identifiable, Decodable {
    let id: String
    let name: String
    let type: String
    let password: String?
}
