//
//  HomeScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 07/03/2025.
//

import SwiftUI

struct HomeScreen: View {
    @ObservedObject var homeViewModel = HomeViewModel()
    @State private var showPasswordField = false
    @State private var password = ""
    @State private var selectedSession: Session?
    @State private var passwordErrorMessage = ""
    @State private var isPasswordCorrect = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Session in progress")
                    .font(.title)
                    .padding()

                // Vérification si des sessions actives existent
                if homeViewModel.activeSessions.isEmpty {
                    Text("No active sessions")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(homeViewModel.activeSessions) { session in
                        HStack {
                            Text(session.name)
                                .font(.title3)

                            Spacer()

                           
                            if session.type == "PRIVATE" {
                                Image(systemName: "lock")
                                Button(action: {
                                    self.selectedSession = session
                                    self.showPasswordField = true
                                }) {
                                    Text("Join")
                                        .foregroundColor(.blue)
                                        .padding(.horizontal)
                                }
                            } else {
                                NavigationLink(destination: SessionScreen(nameSession: session.name, nameAdmin: "Admin")) {
                                    Text("Join")
                                        .foregroundColor(.blue)
                                        .padding(.horizontal)
                                }

                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .listStyle(PlainListStyle())
                }

                Spacer()

                // Bouton pour créer une nouvelle session
                NavigationLink(destination: CreationSessionScreen()) {
                    Text("Create session")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .onAppear {
                // Récupérer les sessions actives depuis l'API
                homeViewModel.fetchActiveSessions { success, error in
                    if !success {
                        print("Erreur: \(error ?? "Inconnue")")
                    }
                }
            }

            // Afficher le champ de mot de passe si nécessaire
            .sheet(isPresented: $showPasswordField) {
                VStack {
                    SecureField("Enter password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding()

                    if !passwordErrorMessage.isEmpty {
                        Text(passwordErrorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }

                    Button("Join Session") {
                        checkPassword()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding()
                }
                .padding()
            }
        }
    }

    // Fonction pour vérifier le mot de passe
    func checkPassword() {
        guard let session = selectedSession else {
            print("Session not found")
            return
        }

        // Simuler l'appel API pour récupérer les détails de la session par ID
        fetchSessionByID(sessionId: session.id) { sessionDetails in
            guard let sessionDetails = sessionDetails else {
                passwordErrorMessage = "Session not found"
                print("Session not found")
                return
            }

            // Comparaison des mots de passe après nettoyage (retirer les espaces et comparer en minuscule)
            let normalizedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let normalizedSessionPassword = sessionDetails.password?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

            print("Session password: \(sessionDetails.password ?? "nil")")
            print("Entered password: \(password)")

            // Vérifier si les mots de passe correspondent
            if normalizedPassword == normalizedSessionPassword {
                // Mot de passe correct
                isPasswordCorrect = true
                showPasswordField = false // Masquer le champ de mot de passe
                print("Password is correct")
                // Naviguer vers la session
                // Vous pouvez naviguer ici vers la session réelle, par exemple avec une NavigationLink
            } else {
                passwordErrorMessage = "Incorrect password"
                print("Password mismatch")
            }
        }
    }

    // Fonction pour récupérer la session par ID via API
    func fetchSessionByID(sessionId: String, completion: @escaping (Session?) -> Void) {
        // Simuler l'appel à l'API pour récupérer les détails de la session
        // Dans un vrai cas, vous ferez une requête API pour obtenir les détails de la session par son ID.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Rechercher la session correspondant à l'ID dans la liste des sessions actives
            if let session = homeViewModel.activeSessions.first(where: { $0.id == sessionId }) {
                completion(session)
            } else {
                completion(nil)
            }
        }
    }
}



#Preview {
    HomeScreen()
}
