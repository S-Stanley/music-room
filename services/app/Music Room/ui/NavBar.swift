//
//  NavBar.swift
//  Music Room
//
//  Created by Nathan Bechon on 12/03/2025.
//

import SwiftUI

struct NavigationScreen: View {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var profileViewModel = ProfileViewModel()
    @StateObject var homeViewModel = HomeViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeScreen(tabSelection: $selectedTab)
                .tag(0)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Accueil")
                }

            ProfileScreen(profileViewModel: profileViewModel, homeViewModel: homeViewModel)
                .tag(1)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profil")
                }
        }
        .onAppear {
            authViewModel.loadUserInfo()
        }
        .navigationBarBackButtonHidden(true)
    }
}


#Preview {
    NavigationScreen()
}



