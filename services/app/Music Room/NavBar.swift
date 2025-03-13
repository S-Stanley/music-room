//
//  NavBar.swift
//  Music Room
//
//  Created by Nathan Bechon on 12/03/2025.
//

import SwiftUI

struct NavigationScreen: View {
    @StateObject var authViewModel = AuthViewModel()

    var body: some View {
        TabView {
            HomeScreen()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Accueil")
                }

            Profile(authViewModel: authViewModel)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profil")
                }
        }
        .onAppear {
            // Vérifier si l'utilisateur est authentifié lors du lancement de la vue
            authViewModel.loadUserInfo()
        }
    }
}


#Preview {
    NavigationScreen()
}



