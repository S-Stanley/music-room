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
            SearchBar(text: $searchQuery, onSearch: {
                musicViewModel.searchMusic(query: searchQuery)
            })


            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(musicViewModel.tracks, id: \.id) { track in
                        TrackRow(track: track, onAdd: {
                            if let playlistId = playlistId {
                                musicViewModel.addMusicToPlaylist(playlistId: playlistId, trackId: String(track.id))
                            } else {
                                print("Erreur: Aucun ID de playlist disponible")
                            }
                        })
                    }
                }
            }


            if let errorMessage = musicViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
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
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 4)
            }
            .padding(.horizontal)
        }
    }
}

struct TrackRow: View {
    let track: Track
    let onAdd: () -> Void
    @ObservedObject var audioPlayer = AudioPlayer.shared // Utilisation du singleton pour observer les changements

    var body: some View {
        HStack(spacing: 8) {
            AsyncImage(url: URL(string: track.album.coverSmall)) { phase in
                if let image = phase.image {
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else if phase.error != nil {
                    Color.red.frame(width: 60, height: 60) // Placeholder en cas d'erreur
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

            HStack {
                // 🔥 Bouton pour jouer/pauser la musique
                Button(action: {
                    if audioPlayer.currentlyPlayingTrackId == track.id {
                        audioPlayer.stop()
                    } else {
                        audioPlayer.play(urlString: track.preview, trackId: track.id)
                    }
                }) {
                    Image(systemName: audioPlayer.currentlyPlayingTrackId == track.id ? "pause.circle.fill" : "play.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 30))
                }

                // 🔥 Bouton pour ajouter à la playlist
                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 30))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}


#Preview {
    MusicScreen()
}
