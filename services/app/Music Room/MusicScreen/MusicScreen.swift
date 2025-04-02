//
//  MusicScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 24/03/2025.
//

import SwiftUI

struct MusicScreen: View {
    @StateObject var musicViewModel = MusicViewModel()
    @State private var searchQuery: String = ""
    var playlistId: String?

    var body: some View {
        VStack {
            Text("Session ID: \(playlistId ?? "Aucune session sélectionnée")")
                           .foregroundColor(.red)
                           .padding()
            
            SearchBar(text: $searchQuery, onSearch: {
                musicViewModel.searchMusic(query: searchQuery)
            })


            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(musicViewModel.tracks, id: \.id) { track in
                        TrackRow(track: track) {
                            if let playlistId = playlistId {
                                musicViewModel.addMusicToPlaylist(playlistId: playlistId, trackId: String(track.id))
                            } else {
                                print("Erreur: Aucun ID de playlist disponible")
                            }
                        }
                    }
                }
            }

            if let errorMessage = musicViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding(.top)
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct SearchBar: View {
    @Binding var text: String
    var onSearch: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Rechercher une musique...", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(8)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)

            Button(action: onSearch) {
                Text("Rechercher")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 4)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
    }
}

struct TrackRow: View {
    let track: Track
    let onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: track.album.coverSmall)) { phase in
                if let image = phase.image {
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else if phase.error != nil {
                    Color.red.frame(width: 60, height: 60)
                } else {
                    ProgressView()
                        .frame(width: 60, height: 60)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(track.artist.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onAdd) {
                Image(systemName: "play.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 30))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.horizontal)
    }
}


#Preview {
    MusicScreen()
}
