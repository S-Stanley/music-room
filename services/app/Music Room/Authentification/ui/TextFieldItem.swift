//
//  TextField.swift
//  Music Room
//
//  Created by Nathan Bechon on 15/12/2024.
//

import SwiftUI

struct TextFieldItem: View {
    var text: String
    @State private var input: String = ""
    
    var body: some View {
        VStack {
            TextField(
                    text,
                    text: $input
            )
            .padding() // Ajoute un espace intérieur pour le confort
                        .frame(maxWidth: .infinity) // Prend toute la largeur disponible
                        .frame(height: 50) // Définit une hauteur fixe
                        .border(Color(red: 235/255, green: 235/255, blue: 235/255), width: 1)
                         // Ajoute un fond gris clair
                        .cornerRadius(8) // Coins arrondis
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
//            .textFieldStyle(RoundedBorderTextFieldStyle)
        }
//        .padding()
    }
}

#Preview {
    TextFieldItem(
        text: "Name"
    )
}
