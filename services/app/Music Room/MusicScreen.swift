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

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Rechercher une musique...", text: $searchQuery)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(8)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)

            Button(action: {
                musicViewModel.searchMusic(query: searchQuery)
            }) {
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

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(musicViewModel.tracks, id: \.id) { track in
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: track.album.coverSmall)) { image in
                                image.resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 60, height: 60)
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

                            Image(systemName: "play.circle.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 30))
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
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

#Preview {
    MusicScreen()
}
