//
//  NavBar.swift
//  Music Room
//
//  Created by Nathan Bechon on 12/03/2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeScreen()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Accueil")
                }
            
            Profile()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profil")
                }
        }
    }
}

