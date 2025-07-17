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
    @Published var passwordErrorMessage: String = ""
    @Published var isPasswordCorrect: Bool = false
    
    func takeToken() -> String {
        guard let user = User.load() else {
            return ("Error")
        }
        return (user.token)
    }
    
    func createSession(name: String, type: String, orderType: String,password: String?, adminToken: String, completion: @escaping (Bool, String?) -> Void) {
        
        guard let user = User.load() else {
            completion(false, nil)
            return
        }
        
        guard let url = URL(string: "http://localhost:5001/playlist/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(user.token, forHTTPHeaderField: "token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var body = "name=\(name)&type=\(type)&adminToken=\(adminToken)&orderType=\(orderType)"
        if let password = password, type == "PRIVATE" {
            body += "&password=\(password)"
        }
        
        print("📤 Données envoyées : \(body)")
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
                    print("✅ Statut HTTP 201 reçu")
                    print("📥 Réponse brute : \(String(data: data, encoding: .utf8) ?? "n/a")")
                    do {
                        let sessionResponse = try JSONDecoder().decode(Session.self, from: data)
                        print("✅ Session créée avec succès, ID: \(sessionResponse.id)")
                        completion(true, sessionResponse.id)
                    } catch {
                        print("❌ Erreur de décodage JSON: \(error.localizedDescription)")
                        completion(false, nil)
                    }
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
            print("In fetchActiveSessions")
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

//                print("✅ Statut HTTP: \(httpResponse.statusCode)")
//                print("📥 Réponse JSON brute: \(String(data: data, encoding: .utf8) ?? "Aucune donnée")")

                if httpResponse.statusCode == 200 {
                    do {
                        let sessions = try JSONDecoder().decode([Session].self, from: data)
                        self.activeSessions = sessions

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
    
    func joinSession(session: Session, password: String?, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "http://localhost:5001/playlist/\(session.id)/join") else {
            print("URL invalide")
            self.passwordErrorMessage = "URL invalide"
            completion(false, nil)
            return
        }
        
        guard let user = User.load() else {
            self.passwordErrorMessage = "Utilisateur non authentifié"
            completion(false, nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(user.token, forHTTPHeaderField: "token")
        
        var bodyString = ""
        
        if let password = password {
            // Encoder le mot de passe uniquement s'il n'est pas nil
            guard let encodedPassword = password.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                print("❌ Erreur lors de l'encodage du mot de passe")
                self.passwordErrorMessage = "Erreur interne"
                completion(false, nil)
                return
            }
            bodyString = "password=\(encodedPassword)"
        }
        
        // Encodage du corps de la requête en UTF-8
        guard let httpBody = bodyString.data(using: .utf8) else {
            print("❌ Erreur lors de l'encodage du corps de la requête")
            self.passwordErrorMessage = "Erreur interne"
            completion(false, nil)
            return
        }
        
        request.httpBody = httpBody
        
        print("🔐 Mot de passe envoyé: \(password ?? "nil")")
        print("📤 Requête body: \(bodyString)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Erreur réseau :", error.localizedDescription)
                    self.passwordErrorMessage = "Erreur réseau"
                    completion(false, nil)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.passwordErrorMessage = "Réponse invalide du serveur"
                    completion(false, nil)
                    return
                }
                
                switch httpResponse.statusCode {
                case 200:
                    print("✅ Mot de passe correct. Accès autorisé.")
                    self.isPasswordCorrect = true
                    self.passwordErrorMessage = ""

                    if let data = data {
                        do {
                            let response = try JSONDecoder().decode(JoinSessionResponse.self, from: data)
                            completion(true, response.user.name)
                        } catch {
                            print("❌ Erreur de décodage JSON :", error)
                            completion(true, nil) // Renvoyer nil pour userId en cas d'erreur de décodage
                        }
                    } else {
                        completion(true, nil) // Renvoyer nil si les données sont nulles
                    }
                    
                case 400:
                    self.passwordErrorMessage = "Mot de passe incorrect ou playlist introuvable"
                    completion(false, nil)
                    
                case 500:
                    self.passwordErrorMessage = "Erreur serveur"
                    completion(false, nil)
                    
                default:
                    self.passwordErrorMessage = "Erreur inconnue (\(httpResponse.statusCode))"
                    completion(false, nil)
                }
            }
        }.resume()
    }
}

struct JoinSessionResponse: Codable {
    let id: String
    let type: String
    let name: String
    let password: String?
    let userId: String
    let createdAt: String
    let updatedAt: String
    let user: UserInfo // 👈 Ajoute ça

        struct UserInfo: Codable {
            let id: String
            let email: String
            let name: String
            let createdAt: String
            let updatedAt: String
        }
}

struct Session: Identifiable, Decodable {
    let id: String
    let name: String
    let type: String
    let password: String?
    let creatorUserName: String?
    let orderType: String
}
