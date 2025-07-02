//
//  MusicScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 24/03/2025.
//

import SwiftUI

struct MusicScreen: View {
    @ObservedObject var playlistViewModel: PlaylistViewModel
    @ObservedObject var musicViewModel: MusicViewModel
    @State private var searchQuery: String = ""
    var playlistId: String?
    @State private var locallyAddedTracks: Set<String> = []

    var body: some View {
        VStack {
            SearchBar(text: $searchQuery, onSearch: {
                musicViewModel.searchMusic(query: searchQuery)
            })

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(
                        (searchQuery.isEmpty ? musicViewModel.tracks : musicViewModel.searchedTracks)
                            .filter { track in
                                searchQuery.isEmpty ? !playlistViewModel.playlistTracks.contains(String(track.id)) : true
                            },
                        id: \.id
                    ) { track in
                        TrackRow(
                            track: track,
                            isAlreadyAdded: playlistViewModel.playlistTracks.contains(String(track.id)) || locallyAddedTracks.contains(String(track.id)),
                            onAdd: {
                                let trackId = String(track.id)
                                locallyAddedTracks.insert(trackId)
                                
                                if let playlistId = playlistId {
                                    musicViewModel.addMusicToPlaylist(playlistId: playlistId, trackId: String(track.id))
                                    playlistViewModel.fetchTracksForPlaylist(playlistId: playlistId) { success, error in
                                        if !success {
                                            print("Erreur lors du chargement des musiques: \(error ?? "Inconnue")")
                                        }
                                    }
                                }
                            }
                        )
                    }
                }
            }

            if let errorMessage = musicViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onChange(of: searchQuery) { newQuery in
            // Réinitialiser la recherche lorsque le texte de recherche change
            if newQuery.isEmpty {
                musicViewModel.searchedTracks = []  // Réinitialiser la recherche lorsqu'on efface le texte
            } else {
                musicViewModel.searchMusic(query: newQuery)
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
        }
    }
}

struct TrackRow: View {
    let track: Track
    let isAlreadyAdded: Bool // ✅ Indique si la musique est déjà ajoutée
    let onAdd: () -> Void
    @ObservedObject var audioPlayer = AudioPlayer.shared

    var body: some View {
        HStack(spacing: 8) {
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

            HStack {
//                Button(action: {
//                    if audioPlayer.currentlyPlayingTrackId == track.id {
//                        audioPlayer.stop()
//                    } else {
//                        audioPlayer.play(urlString: track.preview, trackId: track.id)
//                    }
//                }) {
//                    Image(systemName: audioPlayer.currentlyPlayingTrackId == track.id ? "pause.circle.fill" : "play.circle.fill")
//                        .foregroundColor(.blue)
//                        .font(.system(size: 30))
//                }

                if !isAlreadyAdded { // ✅ Cache le bouton si déjà ajouté
                    Button(action: onAdd) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 30))
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
