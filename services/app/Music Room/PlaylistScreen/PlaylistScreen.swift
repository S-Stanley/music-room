//
//  PlaylistScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 03/04/2025.
//

import SwiftUI

struct PlaylistScreen: View {
    @ObservedObject var playlistViewModel: PlaylistViewModel
    var playlistId: String

    @State private var timer: Timer? = nil

    var body: some View {
        VStack {
            if playlistViewModel.tracks.isEmpty {
                Text("Aucune musique dans cette playlist.")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 5) {
                        ForEach(playlistViewModel.tracks.indices, id: \.self) { index in
                            let track = playlistViewModel.tracks[index]
                            TrackRowPlaylist(
                                track: track,
                                onVote: {
                                    playlistViewModel.voteForTrack(track: track, playlistId: playlistId)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            // Appel initial
            playlistViewModel.fetchTracksForPlaylist(playlistId: playlistId) { success, error in
                if !success {
                    print("Erreur lors du chargement des musiques: \(error ?? "Inconnue")")
                }
            }

            // Déclenche un timer toutes les 5 secondes
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                playlistViewModel.fetchTracksForPlaylist(playlistId: playlistId) { success, error in
                    if !success {
                        print("🔁 Erreur lors du refresh: \(error ?? "Inconnue")")
                    } else {
                        print("🔁 Playlist mise à jour automatiquement")
                    }
                }
            }
        }
        .onDisappear {
            // Nettoyage du timer quand la vue disparaît
            timer?.invalidate()
            timer = nil
        }
    }
}


struct TrackRowPlaylist: View {
    let track: Track
    let onVote: () -> Void

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
            
            Button(action: {
                onVote()
           }) {
               Image(systemName: "heart")
                   .foregroundColor(.red)
                   .padding(8)
               Text("\(track.voteCount ?? 0)") // Affichage du nombre de votes
                   .font(.caption)
                   .foregroundColor(.secondary)
           }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
