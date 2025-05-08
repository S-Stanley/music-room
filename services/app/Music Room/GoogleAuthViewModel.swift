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

            guard let user = result?.user else { return }
            self.userEmail = user.profile?.email ?? ""
            self.isAuthenticated = true
            print("✅ Connecté avec : \(self.userEmail)")

            // Tu peux aussi envoyer `user.idToken` à ton backend ici
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.isAuthenticated = false
        self.userEmail = ""
    }
}

