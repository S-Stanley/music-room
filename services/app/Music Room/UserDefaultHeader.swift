//
//  UserDefaultHeader.swift
//  Music Room
//
//  Created by Nathan Bechon on 19/03/2025.
//

import Foundation

struct User: Codable {
    let id: String
    let email: String
    let token: String

    // Sauvegarder l'utilisateur dans UserDefaults
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "current_user")
        }
    }

    // Récupérer l'utilisateur depuis UserDefaults
    static func load() -> User? {
        if let savedData = UserDefaults.standard.data(forKey: "current_user"),
           let decodedUser = try? JSONDecoder().decode(User.self, from: savedData) {
            return decodedUser
        }
        return nil
    }

    // Supprimer l'utilisateur (déconnexion)
    static func logout() {
        UserDefaults.standard.removeObject(forKey: "current_user")
    }
}
