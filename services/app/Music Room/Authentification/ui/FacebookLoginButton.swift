//
//  FaceBookLogIn.swift
//  Music Room
//
//  Created by Nathan Bechon on 12/05/2025.
//

import SwiftUI
import SwiftUI
import FBSDKLoginKit

struct FacebookLoginButton: UIViewRepresentable {
    func makeUIView(context: Context) -> FBLoginButton {
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        button.delegate = context.coordinator
        return button
    }

    func updateUIView(_ uiView: FBLoginButton, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, LoginButtonDelegate {
        func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
            if let error = error {
                print("❌ Erreur Facebook Login: \(error.localizedDescription)")
                return
            }

            guard let accessToken = AccessToken.current?.tokenString else {
                print("❗ Pas de token Facebook")
                return
            }

            print("✅ Token Facebook obtenu : \(accessToken)")

            // 👉 Tu peux ici appeler ta ViewModel pour envoyer le token au backend
        }

        func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
            print("🔓 Déconnecté de Facebook")
        }
    }
}
