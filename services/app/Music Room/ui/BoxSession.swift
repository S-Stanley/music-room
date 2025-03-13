//
//  Session.swift
//  Music Room
//
//  Created by Nathan Bechon on 12/03/2025.
//

import SwiftUI

struct BoxSession: View {
    var name: String
    var onJoin: () -> Void
    
    var body: some View {
        HStack {
                    Text(name) // ✅ Nom dynamique
                        .font(.headline)
                        .padding(.leading, 10) // Un peu d'air à gauche
                        .lineLimit(1) // Limite à une ligne (optionnel)
                        .truncationMode(.tail) // Coupe si trop long

                    Spacer() // Pousse le bouton à droite

                    Button(action: {
                        onJoin() // Action à déclencher
                    }) {
                        Text("Join")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.trailing, 10) // Un peu d'air à droite
                }
                .frame(height: 60) // Hauteur fixe
                .background(Color.gray.opacity(0.2)) // Fond gris clair
                .cornerRadius(12) // Coins arrondis
                .padding(.horizontal, 20)
    }
}
