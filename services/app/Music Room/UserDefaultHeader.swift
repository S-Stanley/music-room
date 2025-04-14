//
//  UserDefaultHeader.swift
//  Music Room
//
//  Created by Nathan Bechon on 19/03/2025.
//

import Foundation

struct User: Codable {
    let id: String
    var email: String
    let token: String
    let name: String

    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }

    static func load() -> User? {
        if let savedUser = UserDefaults.standard.data(forKey: "currentUser"),
           let decodedUser = try? JSONDecoder().decode(User.self, from: savedUser) {
            return decodedUser
        }
        return nil
    }
}
