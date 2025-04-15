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
    private var currentItem: AVPlayerItem?

    func playPreview(from urlString: String, onFinished: @escaping () -> Void) {
        guard let url = URL(string: urlString) else {
            print("❌ URL invalide pour le preview")
            return
        }

        // Supprime observer précédent
        if let currentItem = currentItem {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: currentItem)
        }

        // Crée un nouvel AVPlayerItem
        let item = AVPlayerItem(url: url)
        currentItem = item
        player = AVPlayer(playerItem: item)
        player?.play()

        // 👇 Ajoute observer spécifique à ce nouvel item
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in
            print("🎧 Fin du morceau détectée par AudioPlayer")
            onFinished()
        }
    }

    func stop() {
        player?.pause()
        player = nil
        currentItem = nil
    }
}
