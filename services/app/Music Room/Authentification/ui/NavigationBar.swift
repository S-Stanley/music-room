//
//  NavigationBar.swift
//  Music Room
//
//  Created by Nathan Bechon on 15/12/2024.
//

import SwiftUI

struct NavigationBar: View {
    @Binding var selectedOption: String // Liaison avec Authentification
    
    var body: some View {
        HStack(spacing: 20) {
            ButtonItem(
                text: "Sign in",
                isActive: selectedOption == "Sign in",
                action: {
                    selectedOption = "Sign in" // Mise à jour de l'état
                }
            )
            ButtonItem(
                text: "Sign up",
                isActive: selectedOption == "Sign up",
                action: {
                    selectedOption = "Sign up" // Mise à jour de l'état
                }
            )
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(red: 230/255, green: 230/255, blue: 230/255))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
    }
}

#Preview {
    NavigationBar(
        selectedOption: Binding<String>
            .constant("Sign in")
    )
}
