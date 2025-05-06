//
//  PlaylistScreen.swift
//  Music Room
//
//  Created by Nathan Bechon on 03/04/2025.
//

import SwiftUI

struct PlaylistScreen: View {
    var orderType: String
    @ObservedObject var playlistViewModel: PlaylistViewModel
    var playlistId: String

    @State private var timer: Timer? = nil
    @State private var isEditing = false

    var body: some View {
        VStack {
            HStack {
                Text("Playlist")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                if orderType == "POSITION" {
                    EditButton()
                        .padding(.trailing)
                        .onTapGesture {
                            isEditing.toggle()
                        }
                }
            }
            .padding()

            if playlistViewModel.tracks.isEmpty {
                Text("Aucune musique dans cette playlist.")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(playlistViewModel.tracks.indices, id: \.self) { index in
                        let track = playlistViewModel.tracks[index]
                        TrackRowPlaylist(
                            track: track,
                            onVote: {
                                if orderType == "VOTE" {
                                    playlistViewModel.voteForTrack(track: track, playlistId: playlistId)
                                }
                            },
                            showVoteButton: orderType == "VOTE" ? true : false
                        )
                    }
                    .onMove(perform: orderType == "POSITION" ? moveTrack : nil)
                }
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            playlistViewModel.fetchTracksForPlaylist(playlistId: playlistId) { success, error in
                if !success {
                    print("Erreur lors du chargement des musiques: \(error ?? "Inconnue")")
                }
            }

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
            timer?.invalidate()
            timer = nil
        }
    }

    // 🎯 Logique pour déplacer les morceaux
    func moveTrack(from source: IndexSet, to destination: Int) {
        playlistViewModel.moveTrackInPlaylist(from: source, to: destination, playlistId: playlistId)
    }
}



struct TrackRowPlaylist: View {
    let track: Track
    let onVote: () -> Void
    let showVoteButton: Bool
    
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
                if let addedBy = track.addedBy {
                        Text("Ajouté par \(addedBy)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
            }
            Spacer()
            
            if track.voteCount != nil && showVoteButton {
                Button(action: {
                    onVote()
                }) {
                    Image(systemName: "heart")
                        .foregroundColor(.red)
                        .padding(8)
                    Text("\(track.voteCount ?? 0)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
