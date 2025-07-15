//
//  GoogleAuthViewModel.swift
//  Music Room
//
//  Created by Nathan Bechon on 08/05/2025.
//

import GoogleSignIn
import GoogleSignInSwift

class GoogleAuthViewModel: ObservableObject {
    @Published var userEmail: String = ""
    @Published var isAuthenticated: Bool = false

    func signIn() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("❌ Erreur Google Sign-In: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("❌ Impossible de récupérer le token")
                return
            }

            self.userEmail = user.profile?.email ?? ""
            self.sendTokenToBackend(token: idToken)
        }
    }
    


    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.isAuthenticated = false
        self.userEmail = ""
    }
    
    private func sendTokenToBackend(token: String) {
        guard let url = URL(string: "http://localhost:5001/users/gmail/auth") else {
            print("❌ URL invalide")
            return
        }
        print("🔑 idToken: \(token)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "token=\(token)"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Erreur réseau : \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Réponse invalide")
                    return
                }

                switch httpResponse.statusCode {
                case 200:
                    if let data = data {
                        do {
                            let response = try JSONDecoder().decode(SignInResponse.self, from: data)
                            if let id = response.id, let email = response.email, let token = response.token, let name = response.name{
                                let user = User(id: id, email: email, token: token, name: name)
                                user.save()

                                print("✅ Utilisateur connecté via Gmail : \(email)")

                                // MAJ de l'état de ton ViewModel si nécessaire
                                DispatchQueue.main.async {
                                    self.userEmail = email
                                    self.isAuthenticated = true
                                }
                            } else {
                                print("⚠️ Réponse incomplète du serveur")
                            }
                        } catch {
                            print("❌ Erreur lors du décodage : \(error.localizedDescription)")
                        }
                    }
                case 400:
                    print("❌ Requête invalide")
                case 500:
                    print("🔥 Erreur serveur")
                default:
                    print("❗️Code HTTP inattendu : \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
    
    func link() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("❌ Erreur Google Sign-In: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("❌ Impossible de récupérer le token")
                return
            }

            self.userEmail = user.profile?.email ?? ""
            self.sendGoogleTokenToBackendLink(token: idToken)
        }
    }
    
    private func sendGoogleTokenToBackendLink(token googleToken: String) {
        guard let url = URL(string: "http://localhost:5001/users/gmail/auth") else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        // ⬅️ On ajoute le token utilisateur ici
        if let userToken = User.load()?.token {
            request.setValue(userToken, forHTTPHeaderField: "Token") // ✅ Pas "Bearer"
        } else {
            print("⚠️ Aucun token utilisateur trouvé. L'utilisateur est peut-être déconnecté.")
        }

        request.httpBody = "token=\(googleToken)".data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Erreur réseau : \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Réponse invalide")
                    return
                }

                switch httpResponse.statusCode {
                case 200:
                    if let data = data {
                        do {
                            let response = try JSONDecoder().decode(SignInResponse.self, from: data)
                            if let id = response.id, let email = response.email, let token = response.token, let name = response.name{
                                let user = User(id: id, email: email, token: token, name: name)
                                user.save()

                                print("✅ Utilisateur connecté via Gmail : \(email)")

                                // MAJ de l'état de ton ViewModel si nécessaire
                                DispatchQueue.main.async {
                                    self.userEmail = email
                                    self.isAuthenticated = true
                                }
                            } else {
                                print("⚠️ Réponse incomplète du serveur")
                            }
                        } catch {
                            print("❌ Erreur lors du décodage : \(error.localizedDescription)")
                        }
                    }
                case 400:
                    print("❌ Requête invalide")
                case 500:
                    print("🔥 Erreur serveur")
                default:
                    print("❗️Code HTTP inattendu : \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }

}

