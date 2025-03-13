//
//  SessionScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 13/03/2025.
//

import SwiftUI

struct SessionScreen: View {
    var nameSession = "Session 1"
    var nameAdmin = "Admin"
    
    @State private var selectedScreen: String = "Playlist"
    
    var body: some View {
        VStack {
    
            HStack {
                VStack(alignment: .leading) {
                    Text(nameSession)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Admin: \(nameAdmin)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "lock")
                    .font(.system(size: 30))
                    .foregroundColor(.black)
                    .padding(10)
                
                Image(systemName: "person.fill.badge.plus")
                    .font(.system(size: 30))
                    .foregroundColor(.black)
                    .padding(10)
                
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.black)
                    .padding(10)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.top)

            // Barre de navigation
            NavigationBar(selectedOption: $selectedScreen, text: "Playlist", text2: "Add music")
                .padding(.top)

            // Contenu dynamique
            Spacer()
            
            switch selectedScreen {
            case "Playlist":
                PlaylistScreen()
            case "Add music":
                MusicScreen()
            default:
                Text("Unknown action")
                    .font(.title2)
                    .foregroundColor(.red)
            }

            Spacer()

        }
        .padding()
        .background(Color.gray.opacity(0.05).edgesIgnoringSafeArea(.all))
    }
}

struct PlaylistScreen: View {
    var body: some View {
        VStack  {
            Text("Playlist")
        }
    }
}

struct MusicScreen: View {
    var body: some View {
        VStack  {
            Text("Music")
           
        }
    }
}


#Preview {
    SessionScreen()
}
