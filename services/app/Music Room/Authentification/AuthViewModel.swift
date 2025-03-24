//
//  AuthViewModel.swift
//  Music Room
//
//  Created by Nathan Bechon on 07/03/2025.
//

import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var activeSessions: [Session] = []

    func loadUserInfo() {
        if let user = User.load() {
            self.isAuthenticated = true
            self.email = user.email
        }
    }

    func signIn() {
        guard let url = URL(string: "http://localhost:5001/users/email/signin") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "email=\(email)&password=\(password)"
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
                        if let data = data {
                            let decoder = JSONDecoder()
                            do {
                                let response = try decoder.decode(SignInResponse.self, from: data)
                                if let id = response.id, let email = response.email, let token = response.token {
                                    let user = User(id: id, email: email, token: token)
                                    user.save()
                                    print("Utilisateur enregistré :", User.load() ?? "Aucun utilisateur trouvé")

                                    self.isAuthenticated = true
                                    self.email = email
                                }
                            } catch {
                                self.errorMessage = "Erreur lors du décodage de la réponse"
                                print("Erreur de décodage: \(error.localizedDescription)")
                            }
                        }
                case 400:
                    self.errorMessage = "Email ou mot de passe invalide"
                default:
                    self.errorMessage = "Erreur inconnue (\(httpResponse.statusCode))"
                }
            }
        }.resume()
    }

    func signUp() {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Veuillez remplir tous les champs."
            return
        }

        guard let url = URL(string: "http://localhost:5001/users/email/signup") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "email=\(email)&password=\(password)"
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
                    case 201:
                        print("Inscription réussie ✅")
                        self.isAuthenticated = true
                        
                        if let data = data {
                            let decoder = JSONDecoder()
                            do {
                                let response = try decoder.decode(SignInResponse.self, from: data)
                                UserDefaults.standard.set(response.email, forKey: "user_email")
                                UserDefaults.standard.set(response.token, forKey: "auth_token")
                                UserDefaults.standard.set(response.id, forKey: "user_id")
                                self.email = response.email ?? "Email non trouvé"
                            } catch {
                                self.errorMessage = "Erreur lors du décodage de la réponse"
                                print("Erreur de décodage: \(error.localizedDescription)")
                            }
                        }
                    case 400:
                        self.errorMessage = "Cet email est déjà utilisé ❌"
                    case 500:
                        self.errorMessage = "Erreur serveur. Veuillez réessayer plus tard."
                    default:
                        self.errorMessage = "Erreur inconnue (\(httpResponse.statusCode))"
                }
            }
        }.resume()
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
                        let updatedUser = User(id: user.id, email: newEmail, token: user.token)
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
                        self.password = newPassword // Mettre à jour l'interface utilisateur
                        
                        // Sauvegarde les nouvelles infos de l'utilisateur (même si ici c'est juste le mot de passe)
                        let updatedUser = User(id: user.id, email: user.email, token: user.token)
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

    func createSession(name: String, type: String, password: String?, completion: @escaping (Bool) -> Void) {
        guard let user = User.load() else {
            completion(false)
            return
        }
        
        guard let url = URL(string: "http://localhost:5001/playlist/") else { return }

        print("Nom de session: \(name), Type: \(type)")
        print("Requête envoyée à l'API")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(user.token, forHTTPHeaderField: "token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var body = "name=\(name)&type=\(type)"
        if let password = password, type == "PRIVATE" {
            body += "&password=\(password)"
        }
        
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Erreur: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(false)
                    return
                }

                if httpResponse.statusCode == 201 {
                    print("Session créée avec succès ✅")
                    completion(true)
                } else {
                    print("Erreur lors de la création: \(httpResponse.statusCode)")
                    completion(false)
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
    let password: String?// 🔹 Modifier "admin" en "type"
}



struct SignInResponse: Codable {
    let id: String?
    let email: String?
    let token: String?
    let error: String?
}
