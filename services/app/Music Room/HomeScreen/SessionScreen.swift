//
//  SessionScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 13/03/2025.
//

import SwiftUI

struct SessionScreen: View {
    @StateObject var homeViewModel = HomeViewModel()
    var sessionId: String
    var nameSession: String
    var nameAdmin: String

    @State private var selectedScreen: String = "Playlist"
    @Environment(\.presentationMode) var presentationMode

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
                
                Button(action: {
                    quitterLaSession()
                }) {
                    Text("Quitter la session")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                Image(systemName: "lock")
                    .foregroundColor(.black)
                    .font(.system(size: 30))
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.black)
                    .font(.system(size: 30))
            }
            
            // Barre de navigation
            NavigationBar(selectedOption: $selectedScreen, text: "Playlist", text2: "Add music")


            Spacer()

            switch selectedScreen {
            case "Playlist":
                PlaylistScreen(playlistId: sessionId)
            case "Add music":
                MusicScreen(playlistId: sessionId)
            default:
                Text("Unknown action")
                    .font(.title2)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05).edgesIgnoringSafeArea(.all))
        .navigationBarBackButtonHidden(true)
    }

    func quitterLaSession() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct PlaylistScreen: View {
    @StateObject var musicViewModel = MusicViewModel()
    var playlistId: String

    var body: some View {
        VStack {
            if musicViewModel.tracks.isEmpty {
               
                Text("Aucune musique dans cette playlist.")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 5) {
                        ForEach(musicViewModel.tracks, id: \.id) { track in
                            TrackRow(track: track, onAdd: {})
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            // Assure-toi que la playlist est bien récupérée
            musicViewModel.fetchTracksForPlaylist(playlistId: playlistId) { success, error in
                if !success {
                    print("Erreur lors du chargement des musiques: \(error ?? "Inconnue")")
                }
            }
        }
    }
}




