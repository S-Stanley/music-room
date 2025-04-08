//
//  PlaylistScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 03/04/2025.
//

import SwiftUI

struct PlaylistScreen: View {
    @ObservedObject var musicViewModel: MusicViewModel
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
                        ForEach(musicViewModel.tracks.indices, id: \.self) { index in
                            let track = musicViewModel.tracks[index]
                            TrackRowPlaylist(track: track, onAdd: {})
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

struct TrackRowPlaylist: View {
    let track: Track
    let onAdd: () -> Void
    

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
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
