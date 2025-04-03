//
//  AudioPlayer.swift
//  Music Room
//
//  Created by Nathan Bechon on 03/04/2025.
//

import SwiftUI
import AVFoundation
import Combine

class AudioPlayer: ObservableObject {
    static let shared = AudioPlayer()

    private var player: AVPlayer?
    @Published var currentlyPlayingTrackId: Int? // Stocke l’ID du morceau en cours

    func play(urlString: String, trackId: Int) {
        stop() // Stopper la musique en cours

        guard let url = URL(string: urlString) else {
            print("❌ URL invalide")
            return
        }

        player = AVPlayer(url: url)
        player?.play()
        currentlyPlayingTrackId = trackId // Mettre à jour l’ID du morceau en cours

        print("▶️ Lecture en cours:", urlString)
    }

    func stop() {
        player?.pause()
        currentlyPlayingTrackId = nil
        print("⏸ Musique arrêtée")
    }
}
